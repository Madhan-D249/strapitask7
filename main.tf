provider "aws" {
  region = var.region
}

# NOTE: Enable ECS Container Insights manually using:
# aws ecs put-account-setting --name containerInsights --value enabled

resource "aws_security_group" "strapi_sg" {
  name   = "strapi_sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_db_instance" "strapi" {
  identifier           = "strapi-db"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.database_username
  password             = var.database_password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
}

resource "aws_ecs_cluster" "madhan_strapi_cluster" {
  name = "madhan-strapi-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/madhan-strapi-app"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "madhan_strapi_task" {
  family                   = "madhan-strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "strapi"
      image = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      environment = [
        { name = "APP_KEYS",             value = var.app_keys },
        { name = "API_TOKEN_SALT",       value = var.api_token_salt },
        { name = "ADMIN_JWT_SECRET",     value = var.admin_jwt_secret },
        { name = "JWT_SECRET",           value = var.jwt_secret },
        { name = "DATABASE_CLIENT",      value = "postgres" },
        { name = "DATABASE_NAME",        value = var.db_name },
        { name = "DATABASE_HOST",        value = aws_db_instance.strapi.address },
        { name = "DATABASE_PORT",        value = "5432" },
        { name = "DATABASE_USERNAME",    value = var.database_username },
        { name = "DATABASE_PASSWORD",    value = var.database_password }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "strapi"
        }
      }
    }
  ])
}

resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "strapi_tg" {
  name        = "strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "1337"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

resource "aws_ecs_service" "madhan_strapi_service" {
  name            = "madhan-strapi-service"
  cluster         = aws_ecs_cluster.madhan_strapi_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.madhan_strapi_task.arn
  desired_count   = 1

  network_configuration {
    subnets         = var.public_subnet_ids
    assign_public_ip = true
    security_groups = [aws_security_group.strapi_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi_listener]
}

# OPTIONAL - CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "StrapiMonitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "ECS/ContainerInsights", "CPUUtilization", "ClusterName", aws_ecs_cluster.madhan_strapi_cluster.name ]
          ],
          title = "Strapi CPU Usage",
          region = var.region
        }
      }
    ]
  })
}

# OPTIONAL - CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU usage is above 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.madhan_strapi_cluster.name
  }
}
