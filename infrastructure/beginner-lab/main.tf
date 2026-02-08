terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "nava-terraform-state-for-students"
    key    = "larasi-beginner-lab-state.tfstate"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "this" {
  id = "vpc-02fb02f6b35b49a55"
}

data "aws_subnet" "this" {
  id = "subnet-075cc0f55c52f431e"
}

resource "aws_security_group" "this" {
  name   = "${var.uni_id}-sg-tf"
  vpc_id = data.aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    User = var.uni_id
    Name = "${var.uni_id}-sg-tf"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-04233b5aecce09244"
  instance_type = "t3.micro"

  subnet_id = data.aws_subnet.this.id

  user_data = base64encode(templatefile("init_script.sh", { uni_id = var.uni_id }))

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  tags = {
    User = var.uni_id
    Name = "${var.uni_id}-instance-tf"
  }
}
