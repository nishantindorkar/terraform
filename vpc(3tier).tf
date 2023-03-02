resource "aws_vpc" "main-vpc" {
  cidr_block       = var.cidr_blocks
  instance_tenancy = "default"

  tags = {
    "Name" = "one-vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_cidr_blocks[0]

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_cidr_blocks[1]

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "web-private1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_cidr_blocks[0]

  tags = {
    Name = "private-web-subnet-1"
  }
}

resource "aws_subnet" "web-private2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_cidr_blocks[1]

  tags = {
    Name = "private-web-subnet-2"
  }
}

resource "aws_subnet" "app-private1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_cidr_blocks[2]

  tags = {
    Name = "private-app-subnet-1"
  }
}

resource "aws_subnet" "app-private2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_cidr_blocks[3]

  tags = {
    Name = "private-app-subnet-2"
  }
}

resource "aws_subnet" "database-private" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_cidr_blocks[4]

  tags = {
    Name = "private-data-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = var.cidr_blocks_defualt
    gateway_id = aws_internet_gateway.gateway.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "pub_sub_asso_1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pub_sub_asso_2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_eip" "elasticip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = var.cidr_blocks_defualt
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "pri_sub_asso_1" {
  subnet_id      = aws_subnet.web-private1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "pri_sub_asso_2" {
  subnet_id      = aws_subnet.web-private2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "pri_sub_asso_3" {
  subnet_id      = aws_subnet.app-private1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "pri_sub_asso_4" {
  subnet_id      = aws_subnet.app-private2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "pri_sub_asso_5" {
  subnet_id      = aws_subnet.database-private.id
  route_table_id = aws_route_table.private-rt.id
}


resource "aws_security_group" "main-sg" {
  name   = "main-sg"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]
  }

  tags = {
    "Name" = "main-sg"
  }
}
