terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "larasi-terraform-state"
    key    = "larasi-lab-state.tfstate"
    region = "eu-north-1"
    profile = "nava-admin"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "nava-admin"
  region = "eu-north-1"
}


resource "aws_security_group" "this" {
  name   = "${var.uni_id}-sg-tf"
  vpc_id = var.vpc_id

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

data "template_file" "this" {
  template = file("init_script.sh")

  vars = {
    uni_id = var.uni_id
  }
}

resource "aws_instance" "web" {
  ami           = "ami-04175dfed7619fb38"
  instance_type = "t3.micro"

  subnet_id = "subnet-0a4b809ee0eb4b83c"

  user_data = base64encode(templatefile("init_script.sh", { uni_id = var.uni_id }))

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  key_name = "lars-work-mac"

  tags = {
    User = var.uni_id
    Name = "${var.uni_id}-instance-tf"
  }
}



























































#data "template_file" "this" {
#  template = file("init_script.sh")
#
#  vars = {
#    uni_id = var.uni_id
#  }
#}
#
#resource "aws_instance" "web" {
#  ami           = "ami-04175dfed7619fb38"
#  instance_type = "t3.micro"
#
#  subnet_id = "subnet-098b2ee2b4fc6d33c"
#
#  vpc_security_group_ids = [
#    "${aws_security_group.allow_ssh_and_http.id}"
#  ]
#
#  user_data = data.template_file.this.rendered
#
#  key_name = "salli-ssh"
#
#  tags = {
#    Name = "${var.uni_id}-tf",
#    User = "${var.uni_id}"
#  }
#}
#
#resource "aws_security_group" "allow_ssh_and_http" {
#  name        = "${var.uni_id}-allow-ssh-and-http"
#  description = "Allow ssh and http connections"
#  vpc_id      = "vpc-0864ffadf65555894"
#
#  ingress {
#    description = "Allow http"
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "${var.uni_id}-webserver-tf",
#    User = "${var.uni_id}"
#  }
#}
#
