output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.standard[0].endpoint
}

output "aurora_cluster_endpoint" {
  description = "The cluster endpoint for the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : null
}

output "aurora_reader_endpoint" {
  description = "The cluster reader endpoint for the Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "db_name" {
  description = "The database name"
  value       = var.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = var.username
  sensitive   = true
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.rds.id
}
