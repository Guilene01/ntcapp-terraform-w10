# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = "172.120.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  
  tags = {
    Name       = "ntc-Vpc"
    env        = "Dev"
    app-name   = "ntc"
    Team       = "wdp"
    created_by = "serge"
  }
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my-vpc.id
  ingress = []
  egress = []
  tags = {
    Name = "ntc-default-sg-restricted"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "ntc-IGW"
  }
}

# Public Subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "ntc-public-sub1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "ntc-public-sub2"
  }
}

# Private Subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "ntc-private-sub1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "ntc-private-sub2"
  }
}

# NAT Gateway
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "ntc-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "ntc-NAT"
  }
  depends_on = [aws_internet_gateway.gw]
}

# Route Tables
resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "ntc-private-rt"
  }
}

resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "ntc-public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}