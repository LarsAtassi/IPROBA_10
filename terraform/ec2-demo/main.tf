terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.region
}

# --- Look up latest Amazon Linux 2023 AMI (x86_64) ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- Use the default VPC & one of its subnets (keeps the demo simple) ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security group allowing HTTP from anywhere (egress open) ---
resource "aws_security_group" "web" {
  name        = "tf-demo-web-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "tf-demo-web-sg"
    Project = "tf-demo"
  }
}

# --- Simple user_data to serve a page on port 80 ---
locals {
  user_data = <<-EOT
    #!/bin/bash
    dnf -y install nginx
    echo "Hello from Terraform on $(hostname)" > /usr/share/nginx/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOT
}

# Pick the first subnet in the default VPC
locals {
  subnet_id = data.aws_subnets.default_vpc_subnets.ids[0]
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = {
    Name    = "tf-demo-web"
    Project = "tf-demo"
  }
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "web_url" {
  description = "Convenience URL"
  value       = "http://${aws_instance.web.public_ip}"
}
