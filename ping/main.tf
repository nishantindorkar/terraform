terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = var.region
  profile = var.profile
}

resource "aws_vpc" "vpc-one" {
  cidr_block = var.cidr_block
  tags = {
    Name = "vpc-one"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc-one.id
  cidr_block = var.public_cidr_block

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subent" {
  vpc_id     = aws_vpc.vpc-one.id
  cidr_block = var.private_cidr_block

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-one.id

  tags = {
    Name = "igw-one"
  }
}

resource "aws_route_table" "route-one" {
  vpc_id = aws_vpc.vpc-one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route-one"
  }
}

resource "aws_route_table_association" "sub_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route-one.id
}

resource "aws_route_table_association" "sub_asso_one" {
  subnet_id      = aws_subnet.private_subent.id
  route_table_id = aws_route_table.route-one.id
}

resource "aws_security_group" "allow_SG" {
  name        = "new-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc-one.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "new-SG"
  }
}

resource "aws_instance" "LAB" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_SG.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = var.ecs_associate_public_ip_address
  tags = {
    Name = "public-one"
  }
}

resource "aws_instance" "LAB1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_SG.id]
  subnet_id                   = aws_subnet.private_subent.id
  associate_public_ip_address = var.ecs_associate_public_ip_address
  tags = {
    Name = "public-two"
  }
}

