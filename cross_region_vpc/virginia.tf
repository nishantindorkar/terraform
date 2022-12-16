provider "aws" {
  profile = var.profile
  region  = var.region[0]
  alias   = "region-virgina"
}

resource "aws_vpc" "vpc-one" {
  provider   = aws.region-virgina
  cidr_block = var.cidr_block[0]
  tags = {
    Name = "vpc-virgina"
  }
}

resource "aws_subnet" "subnet-one" {
  provider   = aws.region-virgina
  vpc_id     = aws_vpc.vpc-one.id
  cidr_block = var.public_cidr_block[0]

  tags = {
    Name = "subnet-virgina"
  }
}

resource "aws_internet_gateway" "igw-one" {
  provider = aws.region-virgina
  vpc_id   = aws_vpc.vpc-one.id

  tags = {
    Name = "igw-one"
  }
}

resource "aws_vpc_peering_connection" "request-peering" {
  provider    = aws.region-virgina
  peer_vpc_id = aws_vpc.vpc-two.id
  vpc_id      = aws_vpc.vpc-one.id
  #auto_accept = true
  peer_region = var.region[1]
}

resource "aws_route_table" "route-one" {
  provider = aws.region-virgina
  vpc_id   = aws_vpc.vpc-one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-one.id
  }

  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.request-peering.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "route-one"
  }
}

resource "aws_route_table_association" "sub_asso_one" {
  provider       = aws.region-virgina
  subnet_id      = aws_subnet.subnet-one.id
  route_table_id = aws_route_table.route-one.id
}

resource "aws_security_group" "allow_SG_one" {
  provider    = aws.region-virgina
  name        = "new-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc-one.id

  dynamic "ingress" {
    for_each = [22, 80]
    iterator = port
    content {
      description = "for vpc virgina"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
  provider                    = aws.region-virgina
  ami                         = var.ami[0]
  instance_type               = var.instance_type
  key_name                    = var.key_name[0]
  vpc_security_group_ids      = [aws_security_group.allow_SG_one.id]
  subnet_id                   = aws_subnet.subnet-one.id
  associate_public_ip_address = var.ecs_associate_public_ip_address
  tags = {
    Name = "virgina-server"
  }
}

