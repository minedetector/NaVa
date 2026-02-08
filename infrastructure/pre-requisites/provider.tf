terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "nava-terraform-state"
    key    = "state.tfstate"
    region = "eu-north-1"
    profile = "nava-admin"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  profile = "nava-admin"
  region = "eu-north-1"
}
