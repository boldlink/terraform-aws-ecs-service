resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "access_logs_bucket" {
  source            = "boldlink/s3/aws"
  version           = "2.5.1"
  bucket            = local.bucket
  force_destroy     = var.force_destroy
  sse_sse_algorithm = "AES256" # For production use aws:kms with your CMK and the proper key policy allowing ebs account to use the cmk
  bucket_acl = {
    acl = "log-delivery-write"
  }
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.json
  tags          = local.tags
}

module "ecs_service_alb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-alb-service"
  family                   = "${var.name}-alb-task-definition"
  enable_execute_command   = var.enable_execute_command
  idle_timeout             = 120
  network_configuration = {
    subnets          = local.private_subnets
    assign_public_ip = true
  }
  # Always redeploy the service when terraform apply is run
  alb_subnets                       = local.public_subnets
  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_role_policy                  = data.aws_iam_policy_document.task_role_policy_doc.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.alb_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  force_new_deployment              = var.force_new_deployment
  path                              = var.path
  tasks_minimum_healthy_percent     = 80
  tasks_maximum_percent             = 150
  propagate_tags                    = "SERVICE"
  tags                              = local.tags
  load_balancer = [{
    container_name = var.name
    container_port = var.containerport
  }]

  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = var.access_logs_enabled
    prefix  = "alb"
  }

  retention_in_days          = var.retention_in_days
  drop_invalid_header_fields = var.drop_invalid_header_fields
  tg_port                    = var.tg_port
  create_load_balancer       = var.create_load_balancer
  enable_autoscaling         = true
  step_scaling_policies = [
    {
      name        = "cpu-policy"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type         = "ChangeInCapacity"
        cooldown                = 300
        metric_aggregation_type = "Average"
        step_adjustments = [
          {
            metric_interval_lower_bound = 0
            metric_interval_upper_bound = 10
            scaling_adjustment          = 1
          },
          {
            metric_interval_lower_bound = 10
            metric_interval_upper_bound = null
            scaling_adjustment          = 2
          }
        ]
      }
    }
  ]
  scheduled_actions = [
    {
      name         = "ecs-scheduled-scale-out"
      schedule     = "cron(0 8 ? * MON-FRI *)"
      min_capacity = 5
      max_capacity = 10
      timezone     = "UTC"
    },
    {
      name         = "ecs-scheduled-scale-in"
      schedule     = "cron(0 20 ? * MON-FRI *)"
      min_capacity = 2
      max_capacity = 4
      timezone     = "UTC"
    }
  ]
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
  # metric_aggregation_type    = "Average"

  # WAF association
  associate_with_waf = true
  web_acl_arn        = module.waf_acl.arn

  # Load balancer sg
  lb_ingress_rules = var.alb_ingress_rules
  depends_on = [
    module.access_logs_bucket,
    module.waf_acl
  ]
}

module "ecs_service_nlb" {
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-nlb-service"
  family                   = "${var.name}-nlb-task-definition"
  enable_execute_command   = var.enable_execute_command
  load_balancer_type       = "network"
  # Always redeploy the service when terraform apply is run
  network_configuration = {
    subnets          = local.private_subnets
    assign_public_ip = true
  }
  alb_subnets                       = local.public_subnets
  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_role_policy                  = data.aws_iam_policy_document.task_role_policy_doc.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.nlb_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  force_new_deployment              = var.force_new_deployment
  path                              = var.path
  tasks_minimum_healthy_percent     = 80
  tasks_maximum_percent             = 150
  tags                              = local.tags

  load_balancer = [{
    container_name = var.name
    container_port = var.containerport
  }]
  access_logs = {
    bucket  = module.access_logs_bucket.id
    enabled = var.access_logs_enabled
    prefix  = "nlb"
  }

  retention_in_days          = var.retention_in_days
  drop_invalid_header_fields = var.drop_invalid_header_fields
  tg_port                    = var.tg_port
  tg_protocol                = "TCP"
  create_load_balancer       = var.create_load_balancer
  enable_autoscaling         = true
  target_scaling_policies = [
    {
      name        = "cpu-target-tracking"
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        target_value       = 75
        scale_in_cooldown  = 300
        scale_out_cooldown = 300
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    },
    {
      name        = "memory-target-tracking"
      policy_type = "TargetTrackingScaling"
      target_tracking_scaling_policy_configuration = {
        target_value       = 80
        scale_in_cooldown  = 300
        scale_out_cooldown = 300
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  ]

  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace

  # Load balancer sg
  lb_ingress_rules = var.nlb_ingress_rules
  depends_on       = [module.access_logs_bucket]
}

module "ecs_service_fargate_spot" {
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  source                   = "../../"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  name                     = "${var.name}-fargate-spot-service"
  family                   = "${var.name}-fargate-spot-task-definition"
  enable_execute_command   = var.enable_execute_command

  # Use capacity provider strategy instead of launch_type for FARGATE_SPOT
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]

  network_configuration = {
    subnets          = local.private_subnets
    assign_public_ip = true
  }

  cluster                           = local.cluster
  vpc_id                            = local.vpc_id
  task_assume_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_role_policy                  = data.aws_iam_policy_document.task_role_policy_doc.json
  task_execution_assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy        = local.task_execution_role_policy_doc
  container_definitions             = local.fargate_spot_container_definitions
  kms_key_id                        = data.aws_kms_alias.supporting_kms.target_key_arn
  force_new_deployment              = var.force_new_deployment
  desired_count                     = 3
  tasks_minimum_healthy_percent     = 50
  tasks_maximum_percent             = 200
  propagate_tags                    = "SERVICE"
  tags = merge(local.tags, {
    CostOptimization = "fargate-spot"
    Service          = "fargate-spot-demo"
  })

  # Service security group rules for direct access (no load balancer)
  service_ingress_rules = [
    {
      from_port   = var.containerport
      to_port     = var.containerport
      protocol    = "tcp"
      description = "HTTP access to fargate spot service"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  retention_in_days = var.retention_in_days
}
