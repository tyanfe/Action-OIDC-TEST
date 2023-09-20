module "s3" {
  source = "git@github.com:Kenmakhanu/s3-backend-repo.git//s3-module?ref=v1.2.1"
}

#Backend configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "landmark-automation-kenmak"
    region  = "us-west-2"
    key     = "s3/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "us-west-2"
}