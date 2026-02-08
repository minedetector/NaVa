data "terraform_remote_state" "existing" {
  backend = "s3"
  config = {
    bucket = "nava-terraform-state"
    key    = "state.tfstate"
    region = var.region
  }
}

locals {
  vpc_id                      = "vpc-02fb02f6b35b49a55"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_ids           = [
    "subnet-075cc0f55c52f431e",
    "subnet-0deda9b0ab4690507",
    "subnet-07d8eb94afbed060d"
  ]
  private_subnet_ids          = [
    "subnet-0bdfc835013848e8d",
    "subnet-0d9ece4706152d816",
    "subnet-06cf55ea79ac8da5e"
  ]
  database_subnet_ids         = [
    "subnet-0e0637e027a086783",
    "subnet-0c622d475dc905bf0",
    "subnet-07c332b0e2897959f"
  ]
  ecs_task_execution_role_arn = "arn:aws:iam::187833180667:role/CustomEcsTaskExecutionRole"
  ecs_task_role_arn           = "arn:aws:iam::187833180667:role/CustomEcsTaskRole"
}

#locals {
#  vpc_id                      = data.terraform_remote_state.existing.outputs.vpc_id
#  vpc_cidr = data.terraform_remote_state.existing.outputs.vpc_cidr
#  public_subnet_ids           = data.terraform_remote_state.existing.outputs.public_subnet_ids
#  private_subnet_ids          = data.terraform_remote_state.existing.outputs.private_subnet_ids
#  database_subnet_ids         = data.terraform_remote_state.existing.outputs.database_subnet_ids
#  ecs_task_execution_role_arn = data.terraform_remote_state.existing.outputs.ecs_task_execution_role_arn
#  ecs_task_role_arn           = data.terraform_remote_state.existing.outputs.ecs_task_role_arn
#}

resource "aws_db_subnet_group" "database" {
  name       = "database-subnet-group"
  subnet_ids = local.database_subnet_ids

  tags = {
    Name = "database-subnet-group"
  }
}

resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Security group for RDS"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-sg"
  }
}

resource "aws_db_instance" "wordpress" {
  identifier     = "wordpress"
  engine         = "mysql"
  engine_version = "8.4.7"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "wordpress"
  username = "admin"
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  skip_final_snapshot = true

  tags = {
    Name = "wordpress"
  }
}

resource "aws_ecr_repository" "wordpress" {
  name                 = "wordpress"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "wordpress"
  }
}
