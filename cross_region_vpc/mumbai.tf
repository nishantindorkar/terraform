provider "aws" {
  profile = var.profile
  region  = var.region[1]
  alias   = "region-mumbai"
}

resource "aws_vpc" "vpc-two" {
  provider   = aws.region-mumbai
  cidr_block = var.cidr_block[1]
  tags = {
    Name = "vpc-mumbai"
  }
}

data "aws_availability_zones" "azs" {
  provider = aws.region-mumbai
  #provider = aws.region
  state = "available"
}

resource "aws_subnet" "subnet-two" {
  provider          = aws.region-mumbai
  vpc_id            = aws_vpc.vpc-two.id
  cidr_block        = var.public_cidr_block[1]
  availability_zone = element(data.aws_availability_zones.azs.names, 0)

  tags = {
    Name = "subnet-mumbai"
  }
}

resource "aws_internet_gateway" "igw-two" {
  provider = aws.region-mumbai
  vpc_id   = aws_vpc.vpc-two.id

  tags = {
    Name = "igw-two"
  }
}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-mumbai
  vpc_peering_connection_id = aws_vpc_peering_connection.request-peering.id
  auto_accept               = true
}

resource "aws_route_table" "route-two" {
  provider = aws.region-mumbai
  vpc_id   = aws_vpc.vpc-two.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-two.id
  }

  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.request-peering.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "route-two"
  }
}

resource "aws_route_table_association" "sub_asso" {
  provider       = aws.region-mumbai
  subnet_id      = aws_subnet.subnet-two.id
  route_table_id = aws_route_table.route-two.id
}

resource "aws_security_group" "allow_SG" {
  provider    = aws.region-mumbai
  name        = "new-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc-two.id

  dynamic "ingress" {
    for_each = [22, 80]
    iterator = port
    content {
      description = "for vpc mumbai"
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
    Name = "new-mum-SG"
  }
}

resource "aws_instance" "LAB_ONE" {
  provider                    = aws.region-mumbai
  ami                         = var.ami[1]
  instance_type               = var.instance_type
  key_name                    = var.key_name[1]
  vpc_security_group_ids      = [aws_security_group.allow_SG.id]
  subnet_id                   = aws_subnet.subnet-two.id
  associate_public_ip_address = var.ecs_associate_public_ip_address
  tags = {
    Name = "mumbai-server"
  }
}

