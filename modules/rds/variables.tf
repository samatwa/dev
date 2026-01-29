variable "name" {
  description = "Назва інстансу або кластера"
  type        = string
}

variable "engine" {
  description = "Тип бази даних для звичайного RDS"
  type        = string
  default     = "postgres"
}

variable "engine_cluster" {
  description = "Тип бази даних для Aurora"
  type    = string
  default = "aurora-postgresql"
}

variable "aurora_replica_count" {
  description = "Кількість реплік для читання в кластері Aurora"
  type    = number
  default = 1
}

variable "aurora_instance_count" {
  description = "Загальна кількість інстансів Aurora (1 primary + репліки)"
  type    = number
  default = 2 # 1 primary + 1 replica
}

variable "engine_version" {
  description = "Версія ядра бази даних для звичайного RDS"
  type        = string
  default     = "14.7"
}

variable "instance_class" {
  description = "Клас інстансу бази даних"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Обсяг дискового простору в ГБ (тільки для звичайного RDS)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Назва бази даних, яка буде створена при запуску"
  type = string
}

variable "username" {
  description = "Ім'я користувача адміністратора бази даних"
  type = string
}

variable "password" {
  description = "Пароль адміністратора бази даних"
  type      = string
  sensitive = true
}

variable "vpc_id" {
  description = "ID VPC, в якій будуть розміщені ресурси"
  type = string
}

variable "subnet_private_ids" {
  description = "Список ID приватних підмереж"
  type = list(string)
}

variable "subnet_public_ids" {
  description = "Список ID публічних підмереж"
  type = list(string)
}

variable "publicly_accessible" {
  description = "Чи повинна база даних бути доступною з інтернету"
  type    = bool
  default = false
}

variable "multi_az" {
  description = "Чи створювати базу даних у декількох зонах доступності"
  type    = bool
  default = false
}

variable "parameters" {
  description = "Додаткові параметри для DB Parameter Group"
  type    = map(string)
  default = {}
}

variable "use_aurora" {
  description = "Чи використовувати Aurora Cluster замість звичайної RDS інстанції"
  type    = bool
  default = false
}

variable "backup_retention_period" {
  description = "Період зберігання резервних копій у днях"
  type    = string
  default = ""
}

variable "tags" {
  description = "Теги для ресурсів"
  type    = map(string)
  default = {}
}

variable "db_port" {
  description = "Порт для підключення до бази даних"
  type        = number
  default     = 5432
}

variable "parameter_group_family_aurora" {
  description = "Сімейство параметрів для Aurora Cluster"
  type    = string
  default = "aurora-postgresql15"
}

variable "engine_version_cluster" {
  description = "Версія ядра бази даних для Aurora"
  type    = string
  default = "15.3"
}

variable "parameter_group_family_rds" {
  description = "Сімейство параметрів для звичайної RDS інстанції"
  type    = string
  default = "postgres15"
}
