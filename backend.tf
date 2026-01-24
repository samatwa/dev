terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-kvv"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}