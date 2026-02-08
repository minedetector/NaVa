resource "aws_ssm_parameter" "db_host" {
  name        = "/dev/WORDPRESS_DB_HOST"
  description = "Wordpress RDS endpoint"
  type        = "String"
  value       = aws_db_instance.wordpress.endpoint
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/dev/WORDPRESS_DB_NAME"
  description = "Wordpress RDS Database Name"
  type        = "SecureString"
  value       = aws_db_instance.wordpress.db_name
}

resource "aws_ecs_cluster" "wordpress" {
  name = "Wordpress-Cluster"

  tags = {
    Name = "Wordpress-Cluster"
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wordpress-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = local.ecs_task_role_arn
  execution_role_arn       = local.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name      = "wordpress"
    image     = "187833180667.dkr.ecr.eu-north-1.amazonaws.com/teacher/wordpress:latest"
    essential = true

    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]

    secrets = [
      {
        name      = "WORDPRESS_DB_HOST"
        valueFrom = aws_ssm_parameter.db_host.arn
      },
      {
        name      = "WORDPRESS_DB_NAME"
        valueFrom = aws_ssm_parameter.db_name.arn
      },
      {
        name      = "WORDPRESS_DB_USER"
        valueFrom = "${aws_db_instance.wordpress.master_user_secret[0].secret_arn}:username::"
      },
      {
        name      = "WORDPRESS_DB_PASSWORD"
        valueFrom = "${aws_db_instance.wordpress.master_user_secret[0].secret_arn}:password::"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/wordpress-td"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for ECS service"
  vpc_id      = local.vpc_id

  ingress {
    description     = "AllowHttp"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_lb_target_group" "wordpress" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/wp-admin/images/wordpress-logo.svg"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name = "wordpress-tg"
  }
}

resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_ecs_service" "wordpress" {
  name             = "wordpress-service"
  cluster          = aws_ecs_cluster.wordpress.id
  task_definition  = aws_ecs_task_definition.wordpress.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = local.private_subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name   = "wordpress"
    container_port   = 80
  }

  health_check_grace_period_seconds = 30

  depends_on = [aws_lb_listener_rule.wordpress]

  tags = {
    Name = "wordpress-service"
  }
}
