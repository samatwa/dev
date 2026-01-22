# Інфраструктура для Django-застосунку на EKS

Цей проєкт використовує Terraform для створення необхідної інфраструктури в AWS для запуску Django-застосунку на кластері Kubernetes (EKS). Інфраструктура включає VPC, репозиторій ECR для Docker-образів та кластер EKS. Застосунок розгортається за допомогою Helm-чарту.

## Структура проєкту

```
lesson-7/
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
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf           # Створення кластера
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│
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

## Передумови

*   [Terraform](https://www.terraform.io/downloads.html)
*   [AWS CLI](https://aws.amazon.com/cli/) налаштований з вашими обліковими даними
*   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
*   [Helm](https://helm.sh/docs/intro/install/)
*   [Docker](https://docs.docker.com/get-docker/)

## Кроки розгортання

### 1. Ініціалізація та застосування Terraform

Спочатку ініціалізуйте Terraform, щоб завантажити необхідні провайдери та модулі. Потім застосуйте конфігурацію для створення ресурсів AWS.

```bash
terraform init
terraform apply
```

Підтвердіть дію, ввівши `yes`. Після завершення процесу Terraform створить VPC, репозиторій ECR та кластер EKS. Будуть відображені необхідні виводи для наступних кроків.

### 2. Налаштування kubectl

Використовуйте команду з виводу Terraform, щоб налаштувати `kubectl` для підключення до вашого нового кластера EKS.

```bash
$(terraform output -raw kubeconfig_command)
```

Ви можете перевірити підключення до кластера, перевіривши вузли:

```bash
kubectl get nodes
```

### 3. Створення та завантаження Docker-образу в ECR

1.  **Увійдіть до ECR:**
    Отримайте пароль для входу до вашого репозиторію ECR та увійдіть за допомогою Docker.

    ```bash
    aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)
    ```

2.  **Позначте ваш локальний Docker-образ:**
    Позначте ваш локальний образ Django-застосунку. Замініть `your-django-image:latest` на назву вашого локального образу.

    ```bash
    docker tag django-app:latest $(terraform output -raw ecr_repository_url):latest
    ```

3.  **Завантажте образ в ECR:**

    ```bash
    docker push $(terraform output -raw ecr_repository_url):latest
    ```

### 4. Розгортання Django-застосунку за допомогою Helm

1.  **Переконайтесь, що `values.yaml` налаштовано правильно**

    Файл `charts/django-app/values.yaml` **не повинен** містити URL вашого ECR-репозиторію. Це значення передається динамічно під час розгортання. Переконайтесь, що поле `image.repository` порожнє:

    ```yaml
    # charts/django-app/values.yaml

    image:
      repository: ""
      tag: "latest"
      pullPolicy: IfNotPresent
    # ...
    ```
    Це гарантує, що ваш чарт є гнучким і не містить конфіденційної або специфічної для середовища інформації.

2.  **Встановіть або оновіть Helm-чарт**

    Використовуйте команду `helm upgrade --install`, щоб розгорнути ваш застосунок. Ця команда встановить реліз, якщо він не існує, або оновить його, якщо він вже був встановлений. URL ECR-репозиторію передається динамічно за допомогою прапора `--set`.

    ```bash
    helm upgrade --install my-django-release ./charts/django-app \
      --set image.repository=$(terraform output -raw ecr_repository_url)
    ```

### 5. Доступ до застосунку

Після встановлення Helm-чарту створюється сервіс типу `LoadBalancer` для надання доступу до вашого застосунку.

Щоб отримати зовнішню IP-адресу, виконайте універсальну команду для перегляду всіх сервісів:

```bash
kubectl get svc
```

У списку знайдіть сервіс, що відповідає вашому релізу (наприклад, `my-django-release-django-app`) і має тип `LoadBalancer`. Дочекайтеся, поки в колонці `EXTERNAL-IP` з'явиться IP-адреса.

Після цього ваш застосунок буде доступний за цією IP-адресою у веб-браузері.

## Очищення

Щоб знищити всі створені ресурси, виконайте таку команду:

```bash
terraform destroy
```
