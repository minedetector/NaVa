variable "wordpress_image" {
  description = "WordPress container image URI from ECR"
  type        = string
  default = "187833180667.dkr.ecr.eu-north-1.amazonaws.com/teacher/wordpress:latest"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}
