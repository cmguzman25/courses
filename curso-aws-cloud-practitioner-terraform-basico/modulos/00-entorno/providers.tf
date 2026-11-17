# providers.tf — base for every topic that touches AWS (from Topic 3 on).
# Credentials are NOT written here: Terraform reads them from the AWS_PROFILE
# you choose when entering the container.
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Tags added to every resource. They help you find leftovers in the console (Tag Editor).
  default_tags {
    tags = {
      Project   = "cloud-practitioner-course"
      ManagedBy = "terraform"
    }
  }
}
