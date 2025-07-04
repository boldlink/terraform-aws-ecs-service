# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- major: Remove the WAF KMS and ALB/NLB resources from the module and use external modules to provide these configurations.
- fix: CKV_AWS_260 Ensure no security groups allow ingress from 0.0.0.0:0 to port 80
- fix: CKV_AWS_336 Ensure ECS containers are limited to read-only access to root filesystems
- fix: CKV_AWS_338 Ensure CloudWatch log groups retains logs for at least 1 year
- fix: CKV2_AWS_5 Ensure that Security Groups are attached to another
- fix: CKV_AWS_150 Ensure that Load Balancer has deletion protection enabled
- fix: CKV_AWS_152 Ensure that Load Balancer (Network/Gateway) has cross-zone load balancing enabled
- fix: CKV2_AWS_20 Ensure that ALB redirects HTTP requests into HTTPS ones
- fix: CKV_AWS_261 Ensure HTTP HTTPS Target group defines Healthcheck
- feat: Add EC2 usage example
- feat: Possibly use lb module for load-balancer resource
- feat: Use load-balancer module in example
- feat: Add more options for module cloudwatch log group
- feat: Exclusively use acm certificate (not self_signed_cert) for complete example
- feat: consolidate ecs cluster module and ecs service module into one
- feat: expand volume block of the task definition as it has more configuration
- feat: Add example for service security group using a security group id for `service_ingress_sg`


## [1.13.0] - 2025-07-03
### Changes
- fix: deprecated data.aws_region.current.name attribute by upgrading cluster module to v3.0.0
- fix: VPC data source error by adding state filter to ensure only available VPCs are selected
- fix: resource naming conflicts by adding random suffix to prevent conflicts with existing resources
- fix: multiple EC2 VPCs matched error in complete example data sources
- fix: deprecated data.aws_region.current.name replaced with data.aws_region.current.id in examples
- feat: add capacity provider strategy support for ECS services with FARGATE and FARGATE_SPOT options
- feat: add capacity_provider_strategy variable to allow mixed capacity provider deployments
- feat: add fargate spot service example with capacity provider strategy configuration
- feat: add fargate spot container definitions with cost optimization environment variables
- feat: add random resource generation for unique naming in complete example

## [1.12.2] - 2024-06-10
### Changes
- docs: Improve variables text and change the domain name of the private acm

## [1.12.1] - 2024-06-10
### Changes
- docs: Add sg's to the external-lb example

## [1.12.0] - 2024-05-28
### Changes
- feat: Add progate tags to the ecs service
- feat: Add tags to additional resources that support it

## [1.11.0] - 2024-05-28
### Changes
- feat: Add Step Scaling Policy to ECS Service
- feat: Add Target Tracking Policy to ECS Service
- feat: Add Scheduled Scaling Policy to ECS Service
- feat: Add Application Auto Scaling examples
- fix: change the trigger to plaintimestamp on examples to fix "registry.terraform.io/hashicorp/aws" produced an invalid new value for .triggers["redeployment"]
- tflint: Change the loab balancer block to use a list of maps instead of a map of maps, **this is a breaking change.**
- tflint: Change the reference of index for ecs task definition roles.
- docs: Add better description to some variables.

## [1.10.0] - 2024-05-19
### Changes
- feat: resolve conflict when using service ingress rules with a sg as a source and add support for cidr_blocks and source_security_group_id security group rules groups
- chore: add checkov exception CKV_TF_2 Ensure Terraform module sources use a tag with a version number

## [1.9.0] - 2024-05-14
### Changes
- feat: associate ecs service with an external load balancer & target group

## [1.8.0] - 2023-11-10
### Changes
- feat: Showcased WAF association for the loadbalancer

## [1.7.0] - 2023-11-03
### Changes
- feat: add complete example for alb and nlb service
- feat: Enable ALB idle timeout configuration - this feature only works with ALB and not NLB.
- fix: Separate listeners and target groups according to the `load_balancer_type = "application/network"`.
- fix: Change the complete example s3 bucket policy and acl to support alb+nlb log delivery
- fix: Force the s3 bucket encryption to be `AES256` since nlb only support AES256 or CMK kms encryption.
- feat: Configure the nlb listerner to use TLS by default, note the current complete example doesnt implement end-to-end encyrption.

## [1.6.0] - 2023-10-26
### Changes
- fix: confusing names for assume role policies for both the task role and task execution role
- feat: Added task role policy resource which initially was not there
- feat: Added output for task definition, security groups, load balancer

## [1.5.3] - 2023-09-05
### Changes
- fix: Deploy service without necessarily requiring load balancer. Previously, the task failed to pull images from dockerhub
- used updated ecs cluster (v1.1.1)
- Added container log configuration for complete and fargate examples.

## [1.5.2] - 2023-08-18
### Changes
- fix: Added checkov exception for `CKV2_AWS_28: Ensure public facing ALB are protected by WAF` since currently checkov is not recognizing associated resource for this
- feat: Added resource for associating created load balancer with WAF Regional ACL

## [1.5.1] - 2023-06-12
### Changes
- fix: Only allow LB SG to connect to the service LB
- fix: made access_logs block optional. Previously, it was mandatory
- feat: Allow egress rules to all protocols by default in all the SGs
- feat: Separated SG resource from SG rules resources
- fix: exempted checkov alert CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled" in the examples
- fix: exempted checkov alert CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints" in the examples
- fix: exempted checkov alert CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"

## [1.5.0] - 2023-05-25
### Changes
- `interval` attribute added to ecs service target group health check with default value `30`

## [1.4.0] - 2023-05-17
### Changes
- force_new_deployment attribute added to ecs service resource with default value `false`

## [1.3.0] - 2023-05-17
### Changes
- enable_execute_command attribute added to the ecs service resource with default value `false`

## [1.2.0] - 2023-05-17
### Changes
- Add the dns_name attribute to the load balancer output

## [1.1.7] - 2023-03-24
### Changes
- fix: CKV2_AWS_28 Ensure public facing ALB are protected by WAF
- feat: seperate static values into variables

## [1.1.6] - 2023-02-03
### Changes
- fix : CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
- added new github workflow files

## [1.1.5] - 2022-10-20
### Changes
- fix: CKV_AWS_111 #Ensure IAM policies does not allow write access without constraints
- fix: CKV_AWS_158 #Ensure that CloudWatch Log Group is encrypted by KMS
- hotfix: deployment controller in minimum example
- fix: egress rules for fargate example

## [1.1.4] - 2022-10-10
### Changes
- fix: CKV_AWS_103: "Ensure that load balancer is using TLS 1.2"
- feat: update files
- feat: update github workflows
- feat: Add supporting resources (vpc and ecs cluster)
- feat: Make creation of KMS Key optional (i.e external KMS key can be used)

## [1.1.3] - 2022-08-29
### Changes
- fix: CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
- fix: CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
- feat: update workflow jobs
- feat: restructure ingress and egress conf blocks

## [1.1.2] - 2022-07-28
### Changes
- fix: stopped (scaling activity initiated by (deployment ecs-svc/<number>))
- feat: dynamic rules for load-balancer security group
- feat: dynamic rules for service security group
- fix: Update in-place when `tfplan` or `tfapply` is done(triggered by task-definition resource)

## [1.1.1] - 2022-07-14
### Changes
- fix: CKV2_AWS_20 Ensure that ALB redirects HTTP requests into HTTPS ones

## [1.1.0] - 2022-07-08
### Changes
- Added the `.github/workflow` folder (not supposed to run gitcommit)
- Re-factored examples (`minimum`, `complete` and additional)
- Added `CHANGELOG.md`
- Added `CODEOWNERS`
- Added `versions.tf`, which is important for pre-commit checks
- Added `Makefile` for examples automation
- Added `.gitignore` file

## [1.0.0] - 2022-04-12
### Changes
- fix: description correction
- fix: removed deprecated examples.
- feat: count variables removal
- feat: README & source update
- feat: ecs-service upgrade (#3)
- feat: ec2 example and service auto-scaling
- feat: feature update.
- feat: initial code commit

[Unreleased]: https://github.com/boldlink/terraform-aws-ecs-service/compare/1.12.2...HEAD

[1.12.2]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.12.2
[1.12.1]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.12.1
[1.12.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.12.0
[1.11.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.11.0
[1.10.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.10.0
[1.9.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.9.0
[1.8.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.8.0
[1.7.1]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.7.1
[1.7.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.7.0
[1.6.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.6.0
[1.5.3]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.5.3
[1.5.2]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.5.2
[1.5.1]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.5.1
[1.5.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.5.0
[1.4.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.4.0
[1.3.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.3.0
[1.2.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.2.0
[1.1.7]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.7
[1.1.6]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.6
[1.1.5]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.5
[1.1.4]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.4
[1.1.3]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.3
[1.1.2]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.2
[1.1.1]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.0.0
