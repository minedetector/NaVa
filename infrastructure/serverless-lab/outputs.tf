output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name to access WordPress"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.wordpress.repository_url
  description = "ECR repository URL for WordPress image"
}

output "rds_endpoint" {
  value       = aws_db_instance.wordpress.endpoint
  description = "RDS endpoint"
}

output "rds_secret_arn" {
  value       = aws_db_instance.wordpress.master_user_secret[0].secret_arn
  description = "Secrets Manager secret ARN for RDS credentials"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.wordpress.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.wordpress.name
  description = "ECS service name"
}
