terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
# terraform provider in blocks { }
provider "aws" {
      region = var.region
  }