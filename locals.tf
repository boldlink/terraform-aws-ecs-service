locals {
  create_task_definition = var.deployment_controller_type != "EXTERNAL" && var.create_task_definition ? true : false
  create_lb_sg           = var.create_load_balancer && (length(var.lb_ingress_rules) > 0 || length(var.lb_egress_rules) > 0) ? true : false
  create_svc_sg          = length(var.svc_ingress_rules) > 0 || length(var.svc_egress_rules) > 0 ? true : false
}
