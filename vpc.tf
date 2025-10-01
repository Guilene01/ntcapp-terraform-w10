//This is the code for vpc 

resource "aws_vpc" "my-vpc" {
  cidr_block           = "172.120.0.0/16" // class B 65k
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

// internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "ntc-IGW"
  }
}

// public subnet creation

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.1.0/24" // class c  254 ips 
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ntc-public-sub1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.2.0/24" // class c  254 ips 
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ntc-public-sub2"
  }
  depends_on = [aws_vpc.my-vpc] # dependancy 
}

// subnet creation private
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.3.0/24" // class c  254 ips 
  availability_zone = "us-east-1a"

  tags = {
    Name = "ntc-private-sub1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.4.0/24" // class c  254 ips 
  availability_zone = "us-east-1b"

  tags = {
    Name = "ntc-private-sub2"
  }
}
#nat gateway

resource "aws_eip" "eip" {

}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "ntc-NAT"
  }
}

#route table for private subnet
resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

// route table public 
resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# route table association public

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}

# route table association private
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}
resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}