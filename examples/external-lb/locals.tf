locals {
  public_subnet_id = [
    for i in data.aws_subnet.public : i.id
  ]
  private_subnet_id = [
    for i in data.aws_subnet.private : i.id
  ]
  public_subnets  = local.public_subnet_id
  private_subnets = local.private_subnet_id
  vpc_id          = data.aws_vpc.supporting.id
  cluster         = data.aws_ecs_cluster.ecs.arn
  partition       = data.aws_partition.current.partition
  region          = data.aws_region.current.id
  tags            = merge({ "Name" = var.name }, var.tags)

  default_container_definitions = jsonencode(
    [
      {
        name      = var.name
        image     = var.image
        cpu       = var.cpu
        memory    = var.memory
        essential = var.essential
        portMappings = [
          {
            containerPort = var.containerport
            hostPort      = var.hostport
          }
        ]
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/aws/ecs-service/${var.name}-service",
            awslogs-region        = local.region,
            awslogs-stream-prefix = "task"
          }
        }
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
        Resource = ["arn:${local.partition}:logs:::log-group:${var.name}-service"]
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
