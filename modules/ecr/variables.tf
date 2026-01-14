variable "ecr_name" {
  description = "Ім'я репозиторію ECR"
  type        = string
}

variable "scan_on_push" {
  description = "Чи сканувати образи при завантаженні"
  type        = bool
  default     = true
}
