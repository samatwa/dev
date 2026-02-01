#-------------Backend-----------------
output "s3_bucket_url" {
  description = "URL S3 бакета для стану Terraform"
  value       = module.s3_backend.s3_bucket_url
}

output "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокувань"
  value       = module.s3_backend.dynamodb_table_name
}

#-------------VPC-----------------
output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

#-------------ECR-----------------
output "ecr_repository_url" {
  description = "URL створеного ECR репозиторію"
  value       = module.ecr.ecr_repository_url
}

#-------------EKS-----------------
output "cluster_endpoint" {
  description = "Кінцева точка API EKS для підключення до кластера"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Назва кластера EKS"
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Команда для налаштування kubeconfig"
  value       = module.eks.kubeconfig_command
}

#-------------Jenkins-----------------
output "jenkins_release" {
  description = "Назва релізу Jenkins"
  value       = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  description = "Простір імен, в якому розгорнуто Jenkins"
  value       = module.jenkins.jenkins_namespace
}

#-------------RDS-----------------
output "db_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

#-------------Tools Access Commands-----------------
output "jenkins_login_command" {
  value = "kubectl port-forward svc/jenkins 8080:8080 -n jenkins"
}

output "argocd_login_command" {
  value = "kubectl port-forward svc/argocd-server 8081:443 -n argocd"
}

output "grafana_login_command" {
  value = "kubectl port-forward svc/grafana 3000:80 -n monitoring"
}

output "prometheus_login_command" {
  value = "kubectl port-forward svc/prometheus-server 9090:80 -n monitoring"
}
