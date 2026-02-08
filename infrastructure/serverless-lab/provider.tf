terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "nava-terraform-state"
    key    = "serverless-lab-state.tfstate"
    region = "eu-north-1"
    profile = "nava-admin"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "nava-admin"
  region = "eu-north-1"
}
