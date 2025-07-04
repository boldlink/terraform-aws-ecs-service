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

# Terraform module usage example with fargate configuration

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.ecs_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.supporting_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.supporting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containerport"></a> [containerport](#input\_containerport) | Specify container port | `number` | `5000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to allocate | `number` | `10` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable autoscaling or not for ecs | `bool` | `true` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | Whether this container is essential | `bool` | `true` | no |
| <a name="input_hostport"></a> [hostport](#input\_hostport) | Specify host port | `number` | `5000` | no |
| <a name="input_image"></a> [image](#input\_image) | Name of image to pull from dockerhub | `string` | `"boldlink/flaskapp:latest"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The size of memory to allocate in MiBs | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the stack | `string` | `"fargate-ecs-example"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `"awsvpc"` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days you want to retain log events in the specified log group. | `number` | `1` | no |
| <a name="input_scalable_dimension"></a> [scalable\_dimension](#input\_scalable\_dimension) | The scalable dimension of the scalable target. | `string` | `"ecs:service:DesiredCount"` | no |
| <a name="input_service_ingress_rules"></a> [service\_ingress\_rules](#input\_service\_ingress\_rules) | Ingress rules to add to the service security group. | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow traffic on port 5000. The app is configured to use this port",<br>    "from_port": 5000,<br>    "protocol": "tcp",<br>    "to_port": 5000<br>  }<br>]</pre> | no |
| <a name="input_service_namespace"></a> [service\_namespace](#input\_service\_namespace) | The AWS service namespace of the scalable target. | `string` | `"ecs"` | no |
| <a name="input_supporting_resources_name"></a> [supporting\_resources\_name](#input\_supporting\_resources\_name) | Name of the supporting resources stack | `string` | `"terraform-aws-ecs-service"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | <pre>{<br>  "Department": "DevOps",<br>  "Environment": "example",<br>  "InstanceScheduler": true,<br>  "LayerId": "cExample",<br>  "LayerName": "cExample",<br>  "Owner": "Boldlink",<br>  "Project": "Examples",<br>  "user::CostCenter": "terraform"<br>}</pre> | no |

## Outputs

No outputs.
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
