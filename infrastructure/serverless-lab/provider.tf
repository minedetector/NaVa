terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "nava-terraform-state"
    key    = "serverless-lab-state.tfstate"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
