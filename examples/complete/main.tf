#####
module "vpc" {
  source               = "git::https://github.com/boldlink/terraform-aws-vpc.git?ref=2.0.3"
  cidr_block           = local.cidr_block
  name                 = local.name
  enable_dns_support   = true
  enable_dns_hostnames = true
  account              = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name

  ## public Subnets
  public_subnets          = local.public_subnets
  availability_zones      = local.azs
  map_public_ip_on_launch = true
  tag_env                 = local.tag_env
}

module "kms_key" {
  source                  = "boldlink/kms/aws"
  description             = "A test kms key for ecs cluster"
  create_kms_alias        = true
  alias_name              = "alias/${local.name}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}

resource "aws_cloudwatch_log_group" "cluster" {
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS"
  name              = "${local.name}-log-group"
  retention_in_days = 0
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}

module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.name
  configuration = {
    execute_command_configuration = {
      kms_key_id = module.kms_key.key_id
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }
      logging = "OVERRIDE"
    }
  }
}

module "ecs_service_lb" {
  source = "../../"
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_150:Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_91:Ensure the ELBv2 (Application/Network) has access logging enabled"
  #checkov:skip=CKV_AWS_103:Ensure that load balancer is using TLS 1.2"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  name                     = "${local.name}-service"
  family                   = "${local.name}-task-definition"
  network_configuration = {
    subnets          = flatten(module.vpc.public_subnet_id)
    assign_public_ip = true
  }
  alb_subnets                = flatten(module.vpc.public_subnet_id)
  cluster                    = module.cluster.id
  vpc_id                     = module.vpc.id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
  container_definitions      = local.default_container_definitions
  path                       = "/healthz"
  load_balancer = {
    container_name = local.name
    container_port = 5000
  }
  retention_in_days          = 1
  drop_invalid_header_fields = true
  tg_port                    = 5000
  create_load_balancer       = true
  enable_autoscaling         = true
  scalable_dimension         = "ecs:service:DesiredCount"
  service_namespace          = "ecs"
  lb_ingress_rules = {
    example_lb = {
      from_port   = 443
      to_port     = 443
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  lb_egress_rules = {
    example_lb = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  svc_ingress_rules = {
    example_svc = {
      from_port   = 80
      to_port     = 80
      protocol    = "-1"
      cidr_blocks = [local.cidr_block]
    }
  }

  svc_egress_rules = {
    example_svc = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}
