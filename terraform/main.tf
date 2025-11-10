terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "portfolio-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "portfolio_igw" {
  vpc_id = aws_vpc.portfolio_vpc.id

  tags = {
    Name = "portfolio-igw"
  }
}

# Public Subnet
resource "aws_subnet" "portfolio_subnet" {
  vpc_id                  = aws_vpc.portfolio_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "portfolio-subnet"
  }
}

# Route Table
resource "aws_route_table" "portfolio_rt" {
  vpc_id = aws_vpc.portfolio_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.portfolio_igw.id
  }

  tags = {
    Name = "portfolio-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "portfolio_rta" {
  subnet_id      = aws_subnet.portfolio_subnet.id
  route_table_id = aws_route_table.portfolio_rt.id
}

# Security Group
resource "aws_security_group" "portfolio_sg" {
  name   = "portfolio-sg"
  vpc_id = aws_vpc.portfolio_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "portfolio-sg"
  }
}

# EC2 Instance
resource "aws_instance" "portfolio_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.portfolio_subnet.id
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]
  key_name               = aws_key_pair.portfolio_key.key_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    repo_url = var.github_repo_url
  }))

  tags = {
    Name = "portfolio-server"
  }

  depends_on = [aws_internet_gateway.portfolio_igw]
}

# Key Pair for SSH
resource "aws_key_pair" "portfolio_key" {
  key_name   = "portfolio-key"
  public_key = file(var.public_key_path)
}

# Elastic IP
resource "aws_eip" "portfolio_eip" {
  instance = aws_instance.portfolio_server.id
  domain   = "vpc"

  tags = {
    Name = "portfolio-eip"
  }

  depends_on = [aws_internet_gateway.portfolio_igw]
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# S3 Bucket for backups (optional)
resource "aws_s3_bucket" "portfolio_backup" {
  bucket = "portfolio-backup-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "portfolio-backup"
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
