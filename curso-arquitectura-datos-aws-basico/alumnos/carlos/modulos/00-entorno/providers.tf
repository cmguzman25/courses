# providers.tf
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    cloudwatch     = "http://localstack:4566"
    dynamodb       = "http://localstack:4566"
    events         = "http://localstack:4566"
    firehose       = "http://localstack:4566"
    iam            = "http://localstack:4566"
    kinesis        = "http://localstack:4566"
    kms            = "http://localstack:4566"
    lambda         = "http://localstack:4566"
    logs           = "http://localstack:4566"
    s3             = "http://localstack:4566"
    scheduler      = "http://localstack:4566"
    secretsmanager = "http://localstack:4566"
    sfn            = "http://localstack:4566"
    sns            = "http://localstack:4566"
    sqs            = "http://localstack:4566"
    ssm            = "http://localstack:4566"
    sts            = "http://localstack:4566"
  }

  default_tags {
    tags = {
      Project     = "data-architecture-course"
      Environment = "local"
    }
  }
}
