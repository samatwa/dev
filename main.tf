# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-kvv"
  table_name  = "terraform-locks"
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  vpc_name           = "final-project-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "final-project-ecr"
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"                # Назва кластера
  subnet_ids      = module.vpc.public_subnet_ids      # ID підмереж
  instance_type   = "t3.small"                        # Тип інстансів
  desired_size    = 5                                 # Бажана кількість нодів
  max_size        = 6                                 # Максимальна кількість нодів
  min_size        = 2                                 # Мінімальна кількість нодів
}

module "jenkins" {
  source                     = "./modules/jenkins"
  cluster_name               = module.eks.cluster_name
  oidc_provider_arn          = module.eks.oidc_provider_arn
  oidc_provider_url          = module.eks.oidc_provider_url
  kubeconfig                 = module.eks.kubeconfig_command
  eks_cluster_endpoint       = module.eks.cluster_endpoint
  eks_cluster_ca_certificate = module.eks.eks_cluster_ca_certificate
  eks_cluster_token          = module.eks.eks_cluster_token
  ecr_repository_url         = module.ecr.ecr_repository_url
  db_host                    = module.rds.db_instance_endpoint
  db_name                    = module.rds.db_name
  db_user                    = "postgres"
  db_password                = "admin123456"
}

module "argo_cd" {
  source                     = "./modules/argo_cd"
  namespace                  = "argocd"
  chart_version              = "5.46.4"
  eks_cluster_endpoint       = module.eks.cluster_endpoint
  eks_cluster_ca_certificate = module.eks.eks_cluster_ca_certificate
  eks_cluster_token          = module.eks.eks_cluster_token
}

module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "postgres"
  password                   = "admin123456"
  subnet_private_ids         = module.vpc.private_subnet_ids
  subnet_public_ids          = module.vpc.public_subnet_ids
  publicly_accessible        = true
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = true
  backup_retention_period    = 1
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
} 