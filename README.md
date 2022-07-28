[![Build Status](https://github.com/boldlink/terraform-aws-ecs-service/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/boldlink/terraform-aws-ecs-service/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

## Description
This Terraform module creates an ECS service using either `FARGATE` or `EC2` compatibilities.

Examples available [here](https://github.com/boldlink/terraform-aws-ecs-service/tree/main/examples)

## Usage
*NOTE*: These examples use the latest version of this module

```console
module "cluster" {
  source = "git::https://github.com/boldlink/terraform-aws-ecs-cluster.git?ref=1.0.1"
  name   = local.name
  configuration = {
    execute_command_configuration = {
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
        s3_bucket_encryption_enabled   = false
      }
      logging = "OVERRIDE"
    }
  }
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "${local.name}-log-group"
  retention_in_days = 0
  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
  }
}

module "ecs_service" {
  source                     = "../../"
  name                       = local.name
  cluster                    = module.cluster.id
  deployment_controller_type = "EXTERNAL"

  tags = {
    Name               = local.name
    Environment        = "examples"
    "user::CostCenter" = "terraform-registry"
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.15.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.23.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_appautoscaling_policy.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.lb_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.svc_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.svc_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of ACM generated/third party certificate | `string` | `null` | no |
| <a name="input_adjustment_type"></a> [adjustment\_type](#input\_adjustment\_type) | Required) Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity. | `string` | `"ChangeInCapacity"` | no |
| <a name="input_alb_subnets"></a> [alb\_subnets](#input\_alb\_subnets) | Subnet IDs for the application load balancer. | `list(string)` | `[]` | no |
| <a name="input_autoscale_role_arn"></a> [autoscale\_role\_arn](#input\_autoscale\_role\_arn) | (Optional) The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. | `string` | `null` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Amazon Resource Name (ARN) of cluster which the service runs on | `string` | `null` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world. | `string` | `null` | no |
| <a name="input_cooldown"></a> [cooldown](#input\_cooldown) | (Required) The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | `number` | `60` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `256` | no |
| <a name="input_create_load_balancer"></a> [create\_load\_balancer](#input\_create\_load\_balancer) | Whether to create a load balancer for ecs. | `bool` | `false` | no |
| <a name="input_create_task_definition"></a> [create\_task\_definition](#input\_create\_task\_definition) | Whether to create the task definition or not | `bool` | `true` | no |
| <a name="input_default_type"></a> [default\_type](#input\_default\_type) | Type for default action | `string` | `"forward"` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | (Optional) Type of deployment controller | `string` | `"ECS"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of a task definition | `number` | `2` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application. | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable autoscaling or not for ecs | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_family"></a> [family](#input\_family) | (Required) A unique name for your task definition. | `string` | `null` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `number` | `3` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) If true, the LB will be internal. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS ARN for cloudwatch log group | `string` | `null` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"FARGATE"` | no |
| <a name="input_lb_egress_rules"></a> [lb\_egress\_rules](#input\_lb\_egress\_rules) | (Optional) Egress rules to add to the security group | `any` | `{}` | no |
| <a name="input_lb_ingress_rules"></a> [lb\_ingress\_rules](#input\_lb\_ingress\_rules) | (Optional) Ingress rules to add to the security group | `any` | `{}` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | (Required) The port to listen on for the load balancer | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | (Required) The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL | `string` | `"HTTP"` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (Optional) Configuration block for load balancers | `any` | `[]` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | (Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application. | `string` | `"application"` | no |
| <a name="input_matcher"></a> [matcher](#input\_matcher) | (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s)) | `string` | `"200,202"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | (Required) The max capacity of the scalable target. | `number` | `2` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| <a name="input_metric_aggregation_type"></a> [metric\_aggregation\_type](#input\_metric\_aggregation\_type) | (Optional) The aggregation type for the policy's metrics. Valid values are `Minimum`, `Maximum`, and `Average`. Without a value, AWS will treat the aggregation type as `Average`. | `string` | `"Maximum"` | no |
| <a name="input_metric_interval_lower_bound"></a> [metric\_interval\_lower\_bound](#input\_metric\_interval\_lower\_bound) | (Optional) The lower bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as negative infinity. | `number` | `0` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | (Required) The min capacity of the scalable target. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name. | `string` | n/a | yes |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | (Optional) Network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, and it is not supported for other network modes. | `any` | `{}` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"none"` | no |
| <a name="input_path"></a> [path](#input\_path) | (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS. | `string` | `"/"` | no |
| <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type) | (Optional) The policy type. Valid values are StepScaling and TargetTrackingScaling. Defaults to StepScaling. | `string` | `"StepScaling"` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | `[]` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `7` | no |
| <a name="input_scalable_dimension"></a> [scalable\_dimension](#input\_scalable\_dimension) | (Required) The scalable dimension of the scalable target. | `string` | `""` | no |
| <a name="input_scaling_adjustment"></a> [scaling\_adjustment](#input\_scaling\_adjustment) | (Required) The number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down. | `number` | `2` | no |
| <a name="input_self_signed_cert_common_name"></a> [self\_signed\_cert\_common\_name](#input\_self\_signed\_cert\_common\_name) | Distinguished name | `string` | `"devboldlink.wpengine.com"` | no |
| <a name="input_self_signed_cert_organization"></a> [self\_signed\_cert\_organization](#input\_self\_signed\_cert\_organization) | The organization owning this self signed certificate | `string` | `"Boldlink-SIG"` | no |
| <a name="input_service_namespace"></a> [service\_namespace](#input\_service\_namespace) | (Required) The AWS service namespace of the scalable target. | `string` | `""` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) Name of the SSL Policy for the listener. Required if protocol is `HTTPS` or `TLS` | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_svc_egress_rules"></a> [svc\_egress\_rules](#input\_svc\_egress\_rules) | (Optional) Egress rules to add to the security group | `any` | `{}` | no |
| <a name="input_svc_ingress_rules"></a> [svc\_ingress\_rules](#input\_svc\_ingress\_rules) | (Optional) Ingress rules to add to the security group | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key Value tags to apply to the resources | `map(string)` | `{}` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance. | `string` | `"ip"` | no |
| <a name="input_task_execution_role"></a> [task\_execution\_role](#input\_task\_execution\_role) | Specify the IAM role for task definition task execution | `string` | `null` | no |
| <a name="input_task_execution_role_policy"></a> [task\_execution\_role\_policy](#input\_task\_execution\_role\_policy) | Specify the IAM policy for task definition task execution | `string` | `""` | no |
| <a name="input_task_role_policy"></a> [task\_role\_policy](#input\_task\_role\_policy) | The IAM for task role in task definition | `string` | `""` | no |
| <a name="input_tasks_maximum_percent"></a> [tasks\_maximum\_percent](#input\_tasks\_maximum\_percent) | Upper limit on the number of running tasks. | `number` | `200` | no |
| <a name="input_tasks_minimum_healthy_percent"></a> [tasks\_minimum\_healthy\_percent](#input\_tasks\_minimum\_healthy\_percent) | Lower limit on the number of running tasks. | `number` | `100` | no |
| <a name="input_tg_port"></a> [tg\_port](#input\_tg\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `number` | `80` | no |
| <a name="input_tg_protocol"></a> [tg\_protocol](#input\_tg\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance or ip. Does not apply when target\_type is lambda. | `string` | `"HTTP"` | no |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section. | `string` | `"service-storage"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used by ECS. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of cloudwatch log group |
| <a name="output_iam_role_arn_role"></a> [iam\_role\_arn\_role](#output\_iam\_role\_arn\_role) | The ARN of IAM task role |
| <a name="output_iam_role_create_date_role"></a> [iam\_role\_create\_date\_role](#output\_iam\_role\_create\_date\_role) | Creation date of IAM task role |
| <a name="output_iam_role_id_role"></a> [iam\_role\_id\_role](#output\_iam\_role\_id\_role) | ID of IAM task role |
| <a name="output_iam_role_name_role"></a> [iam\_role\_name\_role](#output\_iam\_role\_name\_role) | Name of IAM task role |
| <a name="output_iam_role_unique_id_role"></a> [iam\_role\_unique\_id\_role](#output\_iam\_role\_unique\_id\_role) | Unique ID of IAM task role |
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

### Makefile
The makefile contained in this repo is optimized for linux paths and the main purpose is to execute testing for now.
* Create all tests:
`$ make tests`
* Clean all tests:
`$ make clean`

#### BOLDLink-SIG 2022
