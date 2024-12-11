# configure aws provider
provider "aws" {
  region = var.region
}

# configure backend
terraform {
  backend "s3" {
    bucket         = "terraformstate-01"
    key            = "aws-eks-terraform.tfstate"
    region         = "ap-south-1"
  }
}