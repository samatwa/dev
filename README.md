# Jenkins + Helm + Terraform + Argo CD

```
lesson-8-9/
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
│   ├── eks/                      # Модуль для Kubernetes кластера
│   │   ├── eks.tf                # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │ 
│   └── argo_cd/             # ✅ Новий модуль для Helm-установки Argo CD
│       ├── argocd.tf       # Helm release для Jenkins
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

## Налаштування Секретів

Перед застосуванням інфраструктури, необхідно налаштувати секрети для доступу до GitHub. Ми створимо два окремі секрети: один для Jenkins, інший для Argo CD.

### 1. Секрет для Jenkins

Цей секрет буде використовуватися Jenkins для клонування репозиторіїв та оновлення Helm-чартів.

1.  **Створіть файл `github-credentials.yaml`** з таким вмістом:
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: github-credentials
      # Важливо: вкажіть той самий namespace, де буде встановлено Jenkins
      namespace: default 
    type: Opaque
    stringData:
      username: "YOUR_GITHUB_USERNAME"
      password: "YOUR_GITHUB_PAT" 
    ```
2.  Замініть `YOUR_GITHUB_USERNAME` та `YOUR_GITHUB_PAT` на ваші дані.
3.  **Застосуйте секрет:**
    ```bash
    kubectl apply -f github-credentials.yaml
    ```

### 2. Секрет для Argo CD

Цей секрет дозволить Argo CD підключитися до вашого Git-репозиторію для синхронізації додатків.

1.  **Створіть файл `argo-repo-secret.yaml`** з таким вмістом:
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: argo-private-repo
      # Важливо: секрет має бути в тому ж неймспейсі, що й Argo CD
      namespace: argo-cd 
      labels:
        # Цей лейбл вказує Argo CD, що це секрет з доступом до репозиторію
        argocd.argoproj.io/secret-type: repository 
    stringData:
      type: git
      url: https://github.com/YOUR_USERNAME/YOUR_REPO.git # URL вашого репозиторію
      username: YOUR_GITHUB_USERNAME
      password: YOUR_GITHUB_PAT
    ```
2.  Замініть плейсхолдери (`YOUR_...`) на ваші реальні дані.
3.  **Застосуйте секрет:**
    ```bash
    kubectl apply -f argo-repo-secret.yaml
    ```
    
**Важливо:** Обидва файли з секретами (`github-credentials.yaml` та `argo-repo-secret.yaml`) додані до `.gitignore`, щоб уникнути їх потрапляння у віддалений репозиторій.

## Як застосувати Terraform

1.  **Ініціалізація:**
    ```bash
    terraform init
    ```
2.  **Планування:**
    ```bash
    terraform plan
    ```
3.  **Застосування:**
    ```bash
    terraform apply
    ```

## Як перевірити Jenkins job

1.  **Отримайте URL та пароль Jenkins:**
    ```bash
    terraform output jenkins_url
    terraform output jenkins_password
    ```
2.  **Перейдіть за URL** у вашому браузері та увійдіть, використовуючи отриманий пароль.
3.  **Знайдіть ваш pipeline job** і перевірте його статус. Ви можете переглянути логи для кожного етапу (Build, Push, Update Chart).

## Як побачити результат в Argo CD

1.  **Отримайте доступ до Argo CD:**
    Спочатку отримайте пароль:
    ```bash
    kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
    Прокиньте порт для доступу до UI:
    ```bash
    kubectl port-forward svc/argocd-server -n argo-cd 8080:443
    ```
2.  **Перейдіть на `https://localhost:8080`** у вашому браузері.
3.  **Увійдіть в Argo CD**, використовуючи ім'я користувача `admin` та пароль, який ви отримали.
4.  **Знайдіть ваш застосунок** (наприклад, `django-app`) і перевірте його статус. Він має бути `Synced` та `Healthy`. Ви можете побачити всі ресурси, які були розгорнуті, та їхній стан.
