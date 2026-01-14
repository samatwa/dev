variable "bucket_name" {
  description = "Ім'я S3 бакета для стану Terraform"
  type        = string
}

variable "table_name" {
  description = "Ім'я таблиці DynamoDB для блокувань Terraform"
  type        = string
}
