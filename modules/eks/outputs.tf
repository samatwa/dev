output "cluster_endpoint" {
  description = "Кінцева точка API-сервера вашого кластера EKS."
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "Назва кластера EKS."
  value       = aws_eks_cluster.eks.name
}

output "kubeconfig_command" {
  description = "Команда для оновлення файлу kubeconfig."
  value       = "aws eks update-kubeconfig --region eu-north-1 --name ${aws_eks_cluster.eks.name}"
}

output "eks_node_role_arn" {
  description = "ARN IAM-ролі для робочих вузлів EKS"
  value       = aws_iam_role.nodes.arn
}
