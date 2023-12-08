#--------------------------------------------------------------------------
# Terraform providers
#--------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region["id"]
}
##############################################################################################################
# Providers variables
############################################################################################################### 
// AWS configuration
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = {
    id  = "eu-west-3" // Paris
    az1 = "eu-west-3a"
    az2 = "eu-west-3c"
  }
}
