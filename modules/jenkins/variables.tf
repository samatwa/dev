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
variable "ecr_repository_url" {
  description = "URL ECR репозиторію"
  type        = string
  default     = ""
}

variable "db_host" {
  description = "Хост бази даних"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "myapp"
}

variable "db_user" {
  description = "Користувач бази даних"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Пароль бази даних"
  type        = string
  sensitive   = true
  default     = ""
}
