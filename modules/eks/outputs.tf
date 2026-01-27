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
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks.name}"
}

output "eks_node_role_arn" {
  description = "ARN IAM-ролі для робочих вузлів EKS"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

output "eks_cluster_token" {
  description = "The token to use for authentication with the cluster."
  value       = data.aws_eks_cluster_auth.eks.token
  sensitive   = true
}
