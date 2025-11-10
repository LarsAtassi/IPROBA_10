terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-north-1"
}

# Bucket name must be globally unique — tweak this string
locals {
  bucket_name = "tf-demo-bucket-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo" {
  bucket = local.bucket_name
  tags = {
    Project = "tf-demo"
    Owner   = "you"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}
