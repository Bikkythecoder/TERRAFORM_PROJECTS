terraform {
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }
}