variable "kubeconfig" {
  description = "Шлях до kubeconfig файлу"
  type        = string
}

variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Кінцева точка кластера EKS"
  type        = string
}

variable "eks_cluster_ca_certificate" {
  description = "Сертифікат автентифікації кластера EKS"
  type        = string
}

variable "eks_cluster_token" {
  description = "Токен для автентифікації в кластері EKS"
  type        = string
  sensitive   = true
}