terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Environments, shared project prefix
locals {
  project      = "terraform-iproba10-demo"
  environments = ["development", "test", "staging", "production"]
}

# S3-Buckets für alle Umgebungen
resource "aws_s3_bucket" "env_bucket" {
  # creates one bucket per environment
  for_each = toset(local.environments)

  # Name muss global einzigartig sein!
  bucket = "${local.project}-${each.key}-bucket"

  tags = {
    Purpose     = "terraform-demo"
    Environment = each.key
  }
}

# Security Group definieren (Firewall-Regeln)
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # erlaubt HTTP von überall
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # erlaubt ausgehenden Traffic
  }
}

# EC2-Instanz erstellen
resource "aws_instance" "web_server" {
  ami           = "ami-0b2ac948e23c57071" # Beispiel-AMI (Amazon Linux 2 in eu-central-1)
  instance_type = "t3.micro"

  # Für neue Accounts ist es sicherer, die SG über ID zuzuordnen:
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name = "my-web-server"
  }
}

# Outputs
# Zeigt alle Bucket-Namen nach Umgebung
output "bucket_names" {
  value = { for env, b in aws_s3_bucket.env_bucket : env => b.bucket }
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}
