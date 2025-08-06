provider "aws" {
  region = var.region
}
locals {
  container_image = "${var.ecr_repo}:${var.image_tag}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "madhan-strapi-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "madhan-strapi-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role" "codedeploy_service_role" {
  name = "madhan-codedeploy-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS" # ✅ Corrected
}

resource "aws_iam_role_policy" "codedeploy_extra_ecs_permissions" {
  name = "AllowECSDescribePermissions"
  role = aws_iam_role.codedeploy_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "madhan_strapi_cluster" {
  name = "madhan-strapi-cluster"
}

resource "aws_cloudwatch_log_group" "madhan_strapi_log_group" {
  name              = "/ecs/madhan-strapi"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "madhan_strapi_task" {
  family                   = "madhan-strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "madhan-strapi"
    image = local.container_image
    essential = true
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]
    environment = [
      { name = "APP_KEYS",          value = var.app_keys },
      { name = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
      { name = "JWT_SECRET",        value = var.jwt_secret },
      { name = "API_TOKEN_SALT",    value = var.api_token_salt }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.madhan_strapi_log_group.name
        awslogs-region        = "us-east-2"
        awslogs-stream-prefix = "ecs/madhan-strapi"
      }
    }
  }])
}

resource "aws_lb" "madhan_strapi_alb" {
  name               = "madhan-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.madhan_alb_sg.id]
  subnets            = ["subnet-0a1e6640cafebb652", "subnet-0f768008c6324831f"]
}

resource "aws_lb_target_group" "madhan_strapi_tg_blue" {
  name        = "madhan-strapi-tg-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = "vpc-06ba36bca6b59f95e"
  target_type = "ip"
  health_check {
    path                = "/admin"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "madhan_strapi_tg_green" {
  name        = "madhan-strapi-tg-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = "vpc-06ba36bca6b59f95e"
  target_type = "ip"
  health_check {
    path                = "/admin"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "madhan_strapi_listener" {
  load_balancer_arn = aws_lb.madhan_strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.madhan_strapi_tg_blue.arn
  }
}

resource "aws_security_group" "madhan_strapi_sg" {
  name        = "madhan-strapi-sg"
  description = "Allow HTTP"
  vpc_id      = "vpc-06ba36bca6b59f95e"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.madhan_alb_sg.id]
    description     = "Allow ALB to access ECS task on port 1337"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "madhan_alb_sg" {
  name        = "madhan-alb-sg"
  description = "Allow inbound HTTP from the internet"
  vpc_id      = "vpc-06ba36bca6b59f95e"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from the internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_codedeploy_app" "madhan_strapi" {
  name              = "madhan-strapi"
  compute_platform  = "ECS"
}

resource "aws_codedeploy_deployment_group" "madhan_strapi_dg" {
  app_name               = aws_codedeploy_app.madhan_strapi.name
  deployment_group_name  = "madhan-strapi-dg"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                            = "TERMINATE"
      termination_wait_time_in_minutes  = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.madhan_strapi_cluster.name
    service_name = aws_ecs_service.madhan_strapi_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.madhan_strapi_listener.arn]
      }
      target_group {
        name = aws_lb_target_group.madhan_strapi_tg_blue.name
      }
      target_group {
        name = aws_lb_target_group.madhan_strapi_tg_green.name
      }
    }
  }
}

resource "aws_ecs_service" "madhan_strapi_service" {
  name            = "madhan-strapi-service"
  cluster         = aws_ecs_cluster.madhan_strapi_cluster.id
  task_definition = aws_ecs_task_definition.madhan_strapi_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = ["subnet-0a1e6640cafebb652", "subnet-0f768008c6324831f"]
    security_groups = [aws_security_group.madhan_strapi_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.madhan_strapi_tg_blue.arn
    container_name   = "madhan-strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.madhan_strapi_listener]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.madhan_strapi_cluster.name
    ServiceName = aws_ecs_service.madhan_strapi_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name          = "HighMemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when memory exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.madhan_strapi_cluster.name
    ServiceName = aws_ecs_service.madhan_strapi_service.name
  }
}

resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "madhan-StrapiDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.madhan_strapi_cluster.name, "ServiceName", aws_ecs_service.madhan_strapi_service.name ],
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.madhan_strapi_cluster.name, "ServiceName", aws_ecs_service.madhan_strapi_service.name ]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-2",
          title = "ECS Service Metrics"
        }
      }
    ]
  })
}  