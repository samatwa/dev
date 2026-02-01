variable "name" {
  description = "Назва Helm-релізу"
  type        = string
  default     = "argo-cd"
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "eks_cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "eks_cluster_token" {
  description = "EKS cluster token"
  type        = string
}

variable "namespace" {
  description = "K8s namespace для Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "chart_version" {
  description = "Версія Argo CD чарта"
  type        = string
  default     = "5.46.4" 
}