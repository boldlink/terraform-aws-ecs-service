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

# Terraform module usage example for fargate with load balancer

### Points to Note
- Add HTTPS inbound rule to load balancer security group for HTTPS to work
- For this example `deletion_protection` is enabled for the load balancer. Change the argument ` enable_deletion_protection = true` to `  enable_deletion_protection = false` or delete it to disable this feature. Terraform will not be able to delete the resource if this feature is not enabled.
- Ensure that traffic on port `5000` is allowed in the ALB security group. This example uses an image that is configured to listen on port `5000`. If you are using your own image, make sure to allow traffic for the port that your application is configured to.
- This example also contains now a NLB configuration, no SSL/TLS is specified for the NLB, so it will be created as a TCP NLB. If you want to use a HTTP NLB, you need to specify a certificate for the NLB. See the [NLB documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html) for more information.
- SSL/TLS support is enabled at the alb/nlb endpoint not end-to-end encryption, the certificate used is a self-signed certificate for testing and example purposes.

## Testing the deployment
To test the deployment, follow these steps:
- Copy the load balancer DNS name.
- Paste the DNS name into the URL bar of your browser.
- Append `/healthz` at the end of the endpoint.
- If the deployment is successful, you should see a `Healthy` message displayed.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access_logs_bucket"></a> [access\_logs\_bucket](#module\_access\_logs\_bucket) | boldlink/s3/aws | 2.5.1 |
| <a name="module_ecs_service_alb"></a> [ecs\_service\_alb](#module\_ecs\_service\_alb) | ../../ | n/a |
| <a name="module_ecs_service_fargate_spot"></a> [ecs\_service\_fargate\_spot](#module\_ecs\_service\_fargate\_spot) | ../../ | n/a |
| <a name="module_ecs_service_nlb"></a> [ecs\_service\_nlb](#module\_ecs\_service\_nlb) | ../../ | n/a |
| <a name="module_waf_acl"></a> [waf\_acl](#module\_waf\_acl) | boldlink/waf/aws | 1.0.3 |

## Resources

| Name | Type |
|------|------|
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.access_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.supporting_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.supporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | Whether to enable access logs for the lb | `bool` | `true` | no |
| <a name="input_alb_ingress_rules"></a> [alb\_ingress\_rules](#input\_alb\_ingress\_rules) | Incoming traffic configuration for the load balancer security group | `list(any)` | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "Allow traffic to load balancer on port 443",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "Allow traffic to alb load balancer on port 80",<br/>    "from_port": 80,<br/>    "protocol": "tcp",<br/>    "to_port": 80<br/>  }<br/>]</pre> | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether to enable cloudwatch metrics | `bool` | `false` | no |
| <a name="input_containerport"></a> [containerport](#input\_containerport) | Specify container port | `number` | `5000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to allocate | `number` | `10` | no |
| <a name="input_create_load_balancer"></a> [create\_load\_balancer](#input\_create\_load\_balancer) | Whether to create a load balancer for ecs. | `bool` | `true` | no |
| <a name="input_custom_header_name"></a> [custom\_header\_name](#input\_custom\_header\_name) | The name of the custom header to insert | `string` | `"X-My-Company-Tracking-ID"` | no |
| <a name="input_custom_header_value"></a> [custom\_header\_value](#input\_custom\_header\_value) | The value of the custom header to insert | `string` | `"1234567890"` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | value to enable execute command at the ecs service, default = false | `bool` | `true` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | Whether this container is essential | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to force bucket deletion | `bool` | `true` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered\_placement\_strategy and placement\_constraints updates. | `bool` | `true` | no |
| <a name="input_hostport"></a> [hostport](#input\_hostport) | Specify host port | `number` | `5000` | no |
| <a name="input_image"></a> [image](#input\_image) | Name of image to pull from dockerhub | `string` | `"boldlink/flaskapp:latest"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The size of memory to allocate in MiBs | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the stack | `string` | `"complete-ecs-example"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"awsvpc"` | no |
| <a name="input_nlb_ingress_rules"></a> [nlb\_ingress\_rules](#input\_nlb\_ingress\_rules) | Incoming traffic configuration for the NLB load balancer security group | `list(any)` | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "Allow traffic to nlb load balancer on port 5000",<br/>    "from_port": 5000,<br/>    "protocol": "tcp",<br/>    "to_port": 5000<br/>  }<br/>]</pre> | no |
| <a name="input_path"></a> [path](#input\_path) | Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS. | `string` | `"/healthz"` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br/>  "FARGATE"<br/>]</pre> | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days you want to retain log events in the specified log group. | `number` | `1` | no |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | Whether to enable simple requests | `bool` | `false` | no |
| <a name="input_scalable_dimension"></a> [scalable\_dimension](#input\_scalable\_dimension) | The scalable dimension of the scalable target. | `string` | `"ecs:service:DesiredCount"` | no |
| <a name="input_service_namespace"></a> [service\_namespace](#input\_service\_namespace) | The AWS service namespace of the scalable target. | `string` | `"ecs"` | no |
| <a name="input_supporting_resources_name"></a> [supporting\_resources\_name](#input\_supporting\_resources\_name) | Name of the supporting resources stack | `string` | `"terraform-aws-ecs-service"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | <pre>{<br/>  "Department": "DevOps",<br/>  "Environment": "example",<br/>  "InstanceScheduler": true,<br/>  "LayerId": "cExample",<br/>  "LayerName": "cExample",<br/>  "Owner": "Boldlink",<br/>  "Project": "Examples",<br/>  "user::CostCenter": "terraform"<br/>}</pre> | no |
| <a name="input_tg_port"></a> [tg\_port](#input\_tg\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance or ip. | `number` | `5000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_service_url"></a> [alb\_service\_url](#output\_alb\_service\_url) | The task definition arn |
| <a name="output_nlb_service_url"></a> [nlb\_service\_url](#output\_nlb\_service\_url) | The task definition arn |
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

#### BOLDLink-SIG 2024
