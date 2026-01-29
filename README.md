# Модуль RDS

Універсальний модуль для розгортання **AWS Aurora Cluster** або звичайної **RDS Instance**.

```
lesson-db-module
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf  
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                        # Модуль для Kubernetes кластера
│   │   ├── eks.tf                  # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf   # Встановлення плагіну csi drive
│   │   ├── variables.tf            # Змінні для EKS
│   │   └── outputs.tf              # Виведення інформації про кластер
│   │
│   ├── rds/                 # Модуль для RDS
│   │   ├── rds.tf           # Створення RDS бази даних  
│   │   ├── aurora.tf        # Створення aurora кластера бази даних  
│   │   ├── shared.tf        # Спільні ресурси  
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   └── outputs.tf  
│   │ 
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │ 
│   └── argo_cd/             # ✅ Новий модуль для Helm-установки Argo CD
│       ├── jenkins.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│		    └──charts/                  # Helm-чарт для створення app'ів
│ 	 	    ├── Chart.yaml
│	  	    ├── values.yaml          # Список applications, repositories
│			    └── templates/
│		        ├── application.yaml
│		        └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища

```

### Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  name                = "myapp-db"
  use_aurora          = false # true для Aurora, false для звичайного RDS
  
  # Налаштування двигуна
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  
  # База даних та доступ
  db_name             = "myappdb"
  username            = "dbadmin"
  password            = "your-secure-password"
  
  # Мережа
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  subnet_public_ids   = module.vpc.public_subnets
  publicly_accessible = false
  
  # Додаткові параметри
  multi_az            = true
  parameters = {
    max_connections = "200"
  }
}
```

### Опис змінних

| Змінна | Опис | Тип | За замовчуванням |
| :--- | :--- | :--- | :--- |
| `name` | Назва ресурсу (буде використана як префікс для SG, PG, Subnet Group) | `string` | - |
| `use_aurora` | Вибір типу БД: `true` — Aurora Cluster, `false` — RDS Instance | `bool` | `false` |
| `engine` | Тип БД (двигун) для звичайного RDS (postgres, mysql, etc.) | `string` | `"postgres"` |
| `engine_cluster` | Тип БД для Aurora (aurora-postgresql, aurora-mysql) | `string` | `"aurora-postgresql"` |
| `engine_version` | Версія двигуна для RDS | `string` | `"14.7"` |
| `engine_version_cluster` | Версія двигуна для Aurora | `string` | `"15.3"` |
| `instance_class` | Клас потужності інстансу (наприклад, `db.t3.micro`) | `string` | `"db.t3.micro"` |
| `allocated_storage` | Обсяг диска в ГБ (тільки для RDS) | `number` | `20` |
| `db_name` | Назва бази даних при створенні | `string` | - |
| `username` | Логін адміністратора | `string` | - |
| `password` | Пароль адміністратора (Sensitive) | `string` | - |
| `vpc_id` | ID VPC для створення Security Group | `string` | - |
| `subnet_private_ids` | Список ID приватних підмереж для Subnet Group | `list(string)` | - |
| `subnet_public_ids` | Список ID публічних підмереж (якщо `publicly_accessible = true`) | `list(string)` | - |
| `publicly_accessible` | Чи дозволяти доступ до БД з публчних мереж | `bool` | `false` |
| `multi_az` | Режим високої доступності (Multi-AZ) | `bool` | `false` |
| `parameters` | Мапа кастомних параметрів для Parameter Group | `map(string)` | `{}` |

### Як змінити конфігурацію

1.  **Тип бази даних**: Використовуйте `use_aurora = true` для кластера Aurora (краще підходить для високих навантажень) або `use_aurora = false` для дешевших інстансів.
2.  **Двигун (Engine)**: Змініть `engine` (для RDS) або `engine_cluster` (для Aurora). Також не забудьте оновити `parameter_group_family_rds` або `parameter_group_family_aurora` відповідно до версії.
3.  **Клас інстансу**: Параметр `instance_class` дозволяє масштабувати ресурси (CPU/RAM).
4.  **Параметри БД**: Модуль автоматично створює `Parameter Group`. Ви можете передати список параметрів через мапу `parameters`, і вони будуть додані до стандартних (`max_connections`, `log_statement`, `work_mem`).
