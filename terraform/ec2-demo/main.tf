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

# S3-Bucket für das Terraform-Demo
resource "aws_s3_bucket" "demo" {
  # Name muss global einzigartig sein!
  bucket = "terraform-iproba10-demo-bucket"

  tags = {
    Purpose = "terraform-demo"
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

# (Optional, aber nett für die Demo) Outputs
output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}