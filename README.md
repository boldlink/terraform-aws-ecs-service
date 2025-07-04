[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-ecs-service/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-ecs-service.svg)](https://github.com/boldlink/terraform-aws-ecs-service/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/module-examples-tests.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/auto-merge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

## Description
This Terraform module creates an ECS service using `FARGATE` compatibilities.

### Why choose this module
- The module follows aws security best practices and uses checkov to ensure compliance.
- Contains elaborate examples that you can use to setup your ecs-service within a very short time.
- Deploy related multiple resources for your application at once

Examples available [here](./examples)

### Troubleshooting ALB Target Group Health Check Failure
If you encounter any health check failures while using this module, please consider the following steps to troubleshoot the issue:

1. Verify Docker Container Port Mapping: Ensure that the port mapping between the Docker container and the host port is accurately configured. Incorrect port mapping can lead to health check failures.

2. Adjust ALB Health Check Interval: Some applications require a longer time to become fully operational. Make sure the health check interval of your Application Load Balancer (ALB) is appropriately set to allow enough time for the application to start and respond to health checks.

3. Validate Target Group Health Check Endpoint: Verify that the endpoint used for the target group health checks is correct and returns a 200 status code. This ensures that the health checks are performed against the intended endpoint.

4. Verify ALB Security Group Inbound Traffic: When using an Application Load Balancer, ensure that the port configured in your application is allowed in the ALB security group's inbound traffic rules. By default, the service security group in this module only permits traffic from the ALB security group for the specified ports. Adjust the security group rules accordingly to allow traffic from the desired ports.

For more detailed information on troubleshooting ALB health check failures, you can refer to this [Stack Overflow post](https://stackoverflow.com/questions/54503360/aws-ecs-error-task-failed-elb-health-checks-in-target-group). It provides additional insights and solutions to common issues related to ALB health checks.

### AWS ECS Service Deployment Control
This module supports AWS ECS Service Deployment Control where it provides the capability to trigger a new deployment for the ECS service, even without changes in the Terraform codebase. This feature ensures that the service is updated with the latest changes, even when using the same image tag instead of semantic versioning.

### Use Case Scenarios:
**Force Deployment:** When deploying an ECS service using the same image tag, triggering a new deployment forces the service to update with the latest changes. This is particularly useful when you want to ensure that the service is always running the latest version of the containerized application, regardless of the image tag. It eliminates the need for manually updating the tag or using semantic versioning for each deployment.

- To take advantage of this feature, ensure the `var.force_new_deployment` variable is set to `true` in your Terraform configuration. For this example, this feature is enabled. Disable it by ensuring the `var.force_new_deployment` to `false`.


## Usage
**NOTE**: These examples use the latest version of this module

```hcl
data "aws_partition" "current" {}

data "aws_ecs_cluster" "ecs" {
  cluster_name = local.supporting_resources_name
}

data "aws_kms_alias" "supporting_kms" {
  name = "alias/${local.supporting_resources_name}"
}

data "aws_vpc" "supporting" {
  filter {
    name   = "tag:Name"
    values = [local.supporting_resources_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.supporting_resources_name}*.pri.*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
```

```hcl
locals {
  private_subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]
  name                      = "minimum-example"
  cluster                   = data.aws_ecs_cluster.ecs.arn
  supporting_resources_name = "terraform-aws-ecs-service"
  vpc_id                    = data.aws_vpc.supporting.id
  private_subnets           = local.private_subnet_id
  partition                 = data.aws_partition.current.partition
  default_container_definitions = jsonencode(
    [
      {
        name      = local.name
        image     = "boldlink/flaskapp:latest"
        cpu       = 10
        memory    = 512
        essential = true
        portMappings = [
          {
            containerPort = 5000
            hostPort      = 5000
          }
        ]
      }
    ]
  )  
  task_execution_role_policy_doc = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [{
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = ["arn:${local.partition}:logs:::log-group:${local.name}"]
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]

          Resource = ["*"]
        }
    ] }
  )
}
```

```hcl
module "ecs_service" {
  source                     = "../../"
  name                       = var.name
  family                     = "${var.name}-task-definition"
  network_mode               = var.network_mode
  cluster                    = local.cluster
  vpc_id                     = local.vpc_id
  task_role_policy           = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role        = data.aws_iam_policy_document.ecs_assume_role_policy.json
  task_execution_role_policy = local.task_execution_role_policy_doc
  container_definitions      = local.default_container_definitions
  kms_key_id                 = data.aws_kms_alias.supporting_kms.target_key_arn
  tags                       = local.tags
  lb_ingress_rules           = var.lb_ingress_rules

  network_configuration = {
    subnets = local.private_subnets
  }
}
```

## Documentation

[AWS ECS Service ](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html)

[Terraform ECS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_appautoscaling_policy.stepscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.targetscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.main_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.lb_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_ingress_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_with_lb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_wafregional_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl_association) | resource |
| [aws_wafv2_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | (Optional) Define an Access Logs block, requires a bucket name and an optional prefix. The S3 bucket must already exist. The default value is false.<br/><br/>  access\_logs = {<br/>    bucket  = string<br/>    enabled = bollean<br/>    prefix  = string<br/>  } | `map(string)` | `{}` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of ACM generated/third party certificate | `string` | `null` | no |
| <a name="input_alb_subnets"></a> [alb\_subnets](#input\_alb\_subnets) | Subnet IDs for the application load balancer. | `list(string)` | `[]` | no |
| <a name="input_associate_with_waf"></a> [associate\_with\_waf](#input\_associate\_with\_waf) | Whether to associate created ALB with AWS WAFv2 ACL | `bool` | `false` | no |
| <a name="input_associate_with_wafregional"></a> [associate\_with\_wafregional](#input\_associate\_with\_wafregional) | Whether to associate created ALB with WAF Regional Web ACL | `bool` | `false` | no |
| <a name="input_autoscale_role_arn"></a> [autoscale\_role\_arn](#input\_autoscale\_role\_arn) | (Optional) The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. | `string` | `null` | no |
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | (Optional) Set of capacity provider strategies to use for the service. Can be one or more. List of maps with the following keys:<br/><br/>capacity\_provider\_strategy = [{<br/>  capacity\_provider = string # Name of the capacity provider (FARGATE, FARGATE\_SPOT, or custom EC2 capacity provider)<br/>  weight           = number # Relative percentage of the total number of launched tasks that should use the specified capacity provider<br/>  base             = number # Number of tasks, at a minimum, to run on the specified capacity provider<br/>}]<br/><br/>Note: Cannot be used in conjunction with launch\_type. If capacity\_provider\_strategy is specified, launch\_type will be ignored. | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = number<br/>    base              = number<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Amazon Resource Name (ARN) of cluster which the service runs on | `string` | `null` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world. | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `256` | no |
| <a name="input_create_load_balancer"></a> [create\_load\_balancer](#input\_create\_load\_balancer) | Whether to create a load balancer for ecs. | `bool` | `false` | no |
| <a name="input_create_task_definition"></a> [create\_task\_definition](#input\_create\_task\_definition) | Whether to create the task definition or not | `bool` | `true` | no |
| <a name="input_default_type"></a> [default\_type](#input\_default\_type) | Type for default action | `string` | `"forward"` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | (Optional) Type of deployment controller | `string` | `"ECS"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of a task definition | `number` | `1` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application. | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable autoscaling or not for ecs | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | value to enable execute command at the ecs service, default = false | `bool` | `false` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Choose whether to enable key rotation | `bool` | `true` | no |
| <a name="input_family"></a> [family](#input\_family) | (Required) A unique name for your task definition. | `string` | `null` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered\_placement\_strategy and placement\_constraints updates. | `bool` | `false` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `number` | `3` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60 | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) If true, the LB will be internal. | `bool` | `false` | no |
| <a name="input_interval"></a> [interval](#input\_interval) | (Optional) Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300. For lambda target groups, it needs to be greater than the timeout of the underlying lambda. Defaults to 30. | `number` | `30` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | The number of days before the key is deleted | `number` | `7` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS ARN for cloudwatch log group | `string` | `null` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. | `string` | `"FARGATE"` | no |
| <a name="input_lb_ingress_rules"></a> [lb\_ingress\_rules](#input\_lb\_ingress\_rules) | Ingress rules to add to the load balancer security group. The rules defined here will be used by service security group<br/><br/>lb\_ingress\_rules = [{<br/>    from\_port   = number<br/>    to\_port     = number<br/>    protocol    = string<br/>    description = string<br/>    cidr\_blocks = list(string)<br/>  }] | `list(any)` | `[]` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | (Required) The port to listen on for the load balancer | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | (Required) The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL | `string` | `"HTTP"` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (Optional) Configuration block when you use a external load balancer, ex shared LB, accepts the following arguments:<br/><br/>load\_balancer = [{<br/>  container\_name   = string<br/>  container\_port   = number<br/>  target\_group\_arn = string<br/>}] | `any` | `[]` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | (Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application. | `string` | `"application"` | no |
| <a name="input_matcher"></a> [matcher](#input\_matcher) | (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s)) | `string` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | (Required) The max capacity of the scalable target. | `number` | `2` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | (Required) The min capacity of the scalable target. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name. | `string` | n/a | yes |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | (Optional) Network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, and it is not supported for other network modes. | `any` | `{}` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"none"` | no |
| <a name="input_path"></a> [path](#input\_path) | (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS. | `string` | `"/"` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | (Optional) Whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION | `string` | `"TASK_DEFINITION"` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | `[]` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `3653` | no |
| <a name="input_scalable_dimension"></a> [scalable\_dimension](#input\_scalable\_dimension) | (Required) The scalable dimension of the scalable target. | `string` | `""` | no |
| <a name="input_scheduled_actions"></a> [scheduled\_actions](#input\_scheduled\_actions) | Scheduled actions to apply to the ecs scalable target. | <pre>list(object({<br/>    name         = string<br/>    schedule     = string<br/>    min_capacity = number<br/>    max_capacity = number<br/>    timezone     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_self_signed_cert_common_name"></a> [self\_signed\_cert\_common\_name](#input\_self\_signed\_cert\_common\_name) | Distinguished name | `string` | `"devboldlink.boldlink.io"` | no |
| <a name="input_self_signed_cert_organization"></a> [self\_signed\_cert\_organization](#input\_self\_signed\_cert\_organization) | The organization owning this self signed certificate | `string` | `"Boldlink-SIG"` | no |
| <a name="input_service_ingress_rules"></a> [service\_ingress\_rules](#input\_service\_ingress\_rules) | Ingress rules to add to the service security group.<br/><br/>  service\_ingress\_rules = [{<br/>      from\_port                = number<br/>      to\_port                  = number<br/>      protocol                 = string<br/>      description              = string<br/>      cidr\_blocks              = list(string)<br/>  }] | `list(any)` | `[]` | no |
| <a name="input_service_ingress_rules_sg"></a> [service\_ingress\_rules\_sg](#input\_service\_ingress\_rules\_sg) | Ingress rules to add to the service security group.<br/><br/>  service\_ingress\_rules = [{<br/>    from\_port                = number<br/>    to\_port                  = number<br/>    protocol                 = string<br/>    description              = string<br/>    source\_security\_group\_id = string<br/>  }] | `list(any)` | `[]` | no |
| <a name="input_service_namespace"></a> [service\_namespace](#input\_service\_namespace) | (Required) The AWS service namespace of the scalable target. | `string` | `"ecs"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) Name of the SSL Policy for the listener. Required if protocol is `HTTPS` or `TLS` | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_step_scaling_policies"></a> [step\_scaling\_policies](#input\_step\_scaling\_policies) | Scaling policies to apply to the scalable target. Supported policy types are StepScaling and TargetTrackingScaling.<br/><br/>  list(object({<br/>      name        = string<br/>      policy\_type = string<br/>      step\_scaling\_policy\_configuration = object({<br/>        adjustment\_type         = string<br/>        cooldown                = number<br/>        metric\_aggregation\_type = string<br/>        step\_adjustments = list(object({<br/>          metric\_interval\_lower\_bound = number<br/>          metric\_interval\_upper\_bound = number<br/>          scaling\_adjustment          = number<br/>        }))<br/>      })<br/>    })) | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key Value tags to apply to the resources | `map(string)` | `{}` | no |
| <a name="input_target_scaling_policies"></a> [target\_scaling\_policies](#input\_target\_scaling\_policies) | Scaling policies to apply to the scalable target. Supported policy types are StepScaling and SepScaling.<br/><br/>  list(object({<br/>    name        = string<br/>    policy\_type = string<br/>    target\_tracking\_scaling\_policy\_configuration = object({<br/>      target\_value       = number<br/>      scale\_in\_cooldown  = number<br/>      scale\_out\_cooldown = number<br/>      predefined\_metric\_specification = object({<br/>        predefined\_metric\_type = string<br/>      })<br/>    })<br/>  })) | `any` | `[]` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance. | `string` | `"ip"` | no |
| <a name="input_task_assume_role_policy"></a> [task\_assume\_role\_policy](#input\_task\_assume\_role\_policy) | The assume role policy for the task role | `string` | `""` | no |
| <a name="input_task_execution_assume_role_policy"></a> [task\_execution\_assume\_role\_policy](#input\_task\_execution\_assume\_role\_policy) | The assume role policy for the task execution role | `string` | `null` | no |
| <a name="input_task_execution_role_policy"></a> [task\_execution\_role\_policy](#input\_task\_execution\_role\_policy) | Specify the IAM policy for task definition task execution | `string` | `""` | no |
| <a name="input_task_role_policy"></a> [task\_role\_policy](#input\_task\_role\_policy) | Specify the IAM policy for task role | `string` | `""` | no |
| <a name="input_tasks_maximum_percent"></a> [tasks\_maximum\_percent](#input\_tasks\_maximum\_percent) | Upper limit on the number of running tasks. | `number` | `200` | no |
| <a name="input_tasks_minimum_healthy_percent"></a> [tasks\_minimum\_healthy\_percent](#input\_tasks\_minimum\_healthy\_percent) | Lower limit on the number of running tasks. | `number` | `100` | no |
| <a name="input_tg_port"></a> [tg\_port](#input\_tg\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `number` | `80` | no |
| <a name="input_tg_protocol"></a> [tg\_protocol](#input\_tg\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `string` | `"HTTP"` | no |
| <a name="input_triggers"></a> [triggers](#input\_triggers) | Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with plaintimestamp()<br/><br/>triggers = {<br/>  redeployment = plantimestamp()<br/>} | `map(string)` | `{}` | no |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section. | `string` | `"service-storage"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used by ECS. | `string` | `null` | no |
| <a name="input_wafregional_acl_id"></a> [wafregional\_acl\_id](#input\_wafregional\_acl\_id) | The ID of WAF Regional Web ACL to associate load balancer with | `string` | `null` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | The ARN of WAF web acl to associate load balancer with | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of cloudwatch log group |
| <a name="output_iam_role_arn_role"></a> [iam\_role\_arn\_role](#output\_iam\_role\_arn\_role) | The ARN of IAM task role |
| <a name="output_iam_role_create_date_role"></a> [iam\_role\_create\_date\_role](#output\_iam\_role\_create\_date\_role) | Creation date of IAM task role |
| <a name="output_iam_role_id_role"></a> [iam\_role\_id\_role](#output\_iam\_role\_id\_role) | ID of IAM task role |
| <a name="output_iam_role_name_role"></a> [iam\_role\_name\_role](#output\_iam\_role\_name\_role) | Name of IAM task role |
| <a name="output_iam_role_unique_id_role"></a> [iam\_role\_unique\_id\_role](#output\_iam\_role\_unique\_id\_role) | Unique ID of IAM task role |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the load balancer (matches `id`) |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | DNS name of load balancer |
| <a name="output_lb_dns_zone_id"></a> [lb\_dns\_zone\_id](#output\_lb\_dns\_zone\_id) | DNS zone id of load balancer |
| <a name="output_lb_sg_arn"></a> [lb\_sg\_arn](#output\_lb\_sg\_arn) | ID of the load balancer security group. |
| <a name="output_lb_sg_id"></a> [lb\_sg\_id](#output\_lb\_sg\_id) | ARN of the load balancer security group. |
| <a name="output_service_sg_arn"></a> [service\_sg\_arn](#output\_service\_sg\_arn) | ID of the service security group. |
| <a name="output_service_sg_id"></a> [service\_sg\_id](#output\_service\_sg\_id) | ARN of the service security group. |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Full ARN of the Task Definition (including both family and revision) |
| <a name="output_task_definition_arn_without_revision"></a> [task\_definition\_arn\_without\_revision](#output\_task\_definition\_arn\_without\_revision) | ARN of the Task Definition with the trailing `revision` removed. This may be useful for situations where the latest task definition is always desired. If a revision isn't specified, the latest ACTIVE revision is used. |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Revision of the task in a particular family. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Third party software
This repository uses third party software:
* [pre-commit](https://pre-commit.com/) - Used to help ensure code and documentation consistency
  * Install with `brew install pre-commit`
  * Manually use with `pre-commit run`
* [terraform 0.14.11](https://releases.hashicorp.com/terraform/0.14.11/) For backwards compatibility we are using version 0.14.11 for testing making this the min version tested and without issues with terraform-docs.
* [terraform-docs](https://github.com/segmentio/terraform-docs) - Used to generate the [Inputs](#Inputs) and [Outputs](#Outputs) sections
  * Install with `brew install terraform-docs`
  * Manually use via pre-commit
* [tflint](https://github.com/terraform-linters/tflint) - Used to lint the Terraform code
  * Install with `brew install tflint`
  * Manually use via pre-commit

### Supporting resources:

The example stacks are used by BOLDLink developers to validate the modules by building an actual stack on AWS.

Some of the modules have dependencies on other modules (ex. Ec2 instance depends on the VPC module) so we create them
first and use data sources on the examples to use the stacks.

Any supporting resources will be available on the `tests/supportingResources` and the lifecycle is managed by the `Makefile` targets.

Resources on the `tests/supportingResources` folder are not intended for demo or actual implementation purposes, and can be used for reference.

### Makefile
The makefile contained in this repo is optimized for linux paths and the main purpose is to execute testing for now.
* Create all tests stacks including any supporting resources:
```console
make tests
```
* Clean all tests *except* existing supporting resources:
```console
make clean
```
* Clean supporting resources - this is done separately so you can test your module build/modify/destroy independently.
```console
make cleansupporting
```
* !!!DANGER!!! Clean the state files from examples and test/supportingResources - use with CAUTION!!!
```console
make cleanstatefiles
```


#### BOLDLink-SIG 2024
