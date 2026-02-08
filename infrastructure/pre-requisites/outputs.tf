output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private app subnet IDs"
}

output "database_subnet_ids" {
  value       = aws_subnet.database[*].id
  description = "Database subnet IDs"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "ECS Task Execution Role ARN"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.ecs_task_role.arn
  description = "ECS Task Role ARN"
}

#output "alb_dns_name" {
#  value       = aws_lb.this.dns_name
#  description = "ALB DNS name"
#}
#
#output "alb_arn" {
#  value       = aws_lb.this.arn
#  description = "ALB ARN"
#}
#
#output "alb_security_group_id" {
#  value       = aws_security_group.this.id
#  description = "ALB Security Group ID"
#}
