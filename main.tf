############################
### ECS Service
############################
resource "aws_ecs_service" "service" {
  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = join("", aws_ecs_task_definition.this.*.arn)
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent
  launch_type                        = var.launch_type

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      assign_public_ip = try(network_configuration.value.assign_public_ip, null)
      security_groups  = [aws_security_group.service[0].id]
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer == [] ? [] : [var.load_balancer]
    content {
      container_name   = lookup(load_balancer.value, "container_name")
      container_port   = lookup(load_balancer.value, "container_port")
      target_group_arn = lookup(load_balancer.value, "target_group_arn", try(aws_lb_target_group.main_tg[0].arn, null))
    }
  }
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

############################
# ECS Task Definition
############################
resource "aws_ecs_task_definition" "this" {
  count                    = local.create_task_definition ? 1 : 0
  family                   = var.family
  task_role_arn            = join("", aws_iam_role.task_role.*.arn)
  execution_role_arn       = join("", aws_iam_role.task_execution_role.*.arn)
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  volume {
    name = var.volume_name
  }
  container_definitions = var.container_definitions
}

############################
# IAM Roles
############################
resource "aws_iam_role" "task_role" {
  count              = local.create_task_definition && var.task_role_policy != "" ? 1 : 0
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = var.task_role_policy
}

resource "aws_iam_role" "task_execution_role" {
  count              = local.create_task_definition && var.task_execution_role_policy != "" ? 1 : 0
  description        = "${var.name} task execution role"
  name               = "${var.name}-task-execution-role"
  assume_role_policy = var.task_execution_role
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count  = var.task_execution_role_policy != "" ? 1 : 0
  name   = "${aws_iam_role.task_execution_role[0].name}-policy"
  role   = aws_iam_role.task_execution_role[0].name
  policy = var.task_execution_role_policy
}

############################
### Cloudwatch Log Group
############################
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs-service/${var.name}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

############################
## Load Balancer
############################
resource "aws_lb" "main" {
  count                      = var.create_load_balancer ? 1 : 0
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.alb_subnets
  security_groups            = [aws_security_group.lb[0].id]
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}

############################
# lb target group
############################
resource "aws_lb_target_group" "main_tg" {
  count       = var.create_load_balancer ? 1 : 0
  name        = var.name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    matcher           = var.matcher
    path              = var.path
    protocol          = var.tg_protocol
    healthy_threshold = var.healthy_threshold
  }
}

#http redirect listener
resource "aws_lb_listener" "http_redirect" {
  count             = var.create_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.main[0].id
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

## Forward redirected traffic to target group
resource "aws_lb_listener" "https" {
  count             = var.create_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.main[0].id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn != null ? var.acm_certificate_arn : aws_acm_certificate.main[0].arn

  default_action {
    type             = var.default_type
    target_group_arn = aws_lb_target_group.main_tg[0].arn
  }
}

###############################################################################################################################################
### NOTE: Self-signed certificates are usually used only in development environments or applications deployed internally to an organization.
### Please use ACM generated certificate in production. Specify the value of `acm_certificate_arn` to provide this
###############################################################################################################################################
resource "tls_private_key" "default" {
  count     = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "default" {
  count           = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  private_key_pem = tls_private_key.default[0].private_key_pem

  subject {
    common_name  = var.self_signed_cert_common_name
    organization = var.self_signed_cert_organization
  }

  validity_period_hours = 72

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "main" {
  count            = var.create_load_balancer && var.acm_certificate_arn == null ? 1 : 0
  private_key      = tls_private_key.default[0].private_key_pem
  certificate_body = tls_self_signed_cert.default[0].cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

# Alb Security group
resource "aws_security_group" "lb" {
  count       = local.create_lb_sg ? 1 : 0
  name        = "${var.name}-lb-security-group"
  vpc_id      = var.vpc_id
  description = "Load balancer security group"
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

resource "aws_security_group_rule" "lb_ingress" {
  for_each          = var.lb_ingress_rules
  type              = "ingress"
  description       = "Allow custom inbound traffic from specific ports."
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks", [])
  security_group_id = aws_security_group.lb[0].id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lb_egress" {
  for_each          = var.lb_egress_rules
  type              = "egress"
  description       = "Allow custom egress traffic"
  from_port         = lookup(each.value, "from_port", 0)
  to_port           = lookup(each.value, "to_port", 0)
  protocol          = "-1"
  cidr_blocks       = lookup(each.value, "cidr_blocks", ["0.0.0.0/0"])
  security_group_id = aws_security_group.lb[0].id
  lifecycle {
    create_before_destroy = true
  }
}

# Service Security group
resource "aws_security_group" "service" {
  count       = local.create_svc_sg ? 1 : 0
  name        = "${var.name}-security-group"
  vpc_id      = var.vpc_id
  description = "Service security group"
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

resource "aws_security_group_rule" "svc_ingress" {
  for_each          = var.svc_ingress_rules
  type              = "ingress"
  description       = "Allow custom inbound traffic from specific ports."
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks", [])
  security_group_id = aws_security_group.service[0].id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "svc_egress" {
  for_each          = var.svc_egress_rules
  type              = "egress"
  description       = "Allow custom egress traffic"
  from_port         = lookup(each.value, "from_port", 0)
  to_port           = lookup(each.value, "to_port", 0)
  protocol          = "-1"
  cidr_blocks       = lookup(each.value, "cidr_blocks", ["0.0.0.0/0"])
  security_group_id = aws_security_group.service[0].id
  lifecycle {
    create_before_destroy = true
  }
}

# Application AutoScaling Resources
resource "aws_appautoscaling_target" "this" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster}/${aws_ecs_service.service.name}"
  role_arn           = var.autoscale_role_arn
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
  depends_on = [
    aws_ecs_service.service
  ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  count              = var.enable_autoscaling ? 1 : 0
  policy_type        = var.policy_type
  name               = "${var.name}-ScaleUp"
  service_namespace  = var.service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type
    cooldown                = var.cooldown
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = var.metric_interval_lower_bound
      scaling_adjustment          = var.scaling_adjustment
    }
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}
