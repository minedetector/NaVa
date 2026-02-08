#resource "aws_security_group" "this" {
#  name_prefix = "alb-allow-http-"
#  description = "Enable HTTP access from internet"
#  vpc_id      = aws_vpc.main.id
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
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
#    Name = "ALBAllowHttp"
#  }
#}
#
#resource "aws_lb" "this" {
#  name               = "NaVa-LB"
#  internal           = false
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.this.id]
#  subnets            = aws_subnet.public[*].id
#
#  tags = {
#    Name = "NaVa-LB"
#  }
#}
