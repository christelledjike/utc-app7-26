# create VPC
resource "aws_vpc" "vp1" {
  cidr_block       = "172.120.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "vpc-utc-app7-26"
    Team = "wdp"
    env  = "dev"
  }
}

# create internet gateway

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vp1.id

}

# create public subnet 1
resource "aws_subnet" "public1" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.vp1.id
  cidr_block              = "172.120.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "utc-public-subnet-1a"
  }
}

# create public subnet 2
resource "aws_subnet" "public2" {
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.vp1.id
  cidr_block              = "172.120.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "utc-public-subnet-1b"
  }

}

# create private subnet 1
resource "aws_subnet" "private1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.vp1.id
  cidr_block        = "172.120.3.0/24"
  tags = {
    Name = "utc-private-subnet-1a"
  }
}

# create private subnet 2
resource "aws_subnet" "private2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vp1.id
  cidr_block        = "172.120.4.0/24"
  tags = {
    Name = "utc-private-subnet-1b"
  }

}

# Create NAT Gateway
resource "aws_eip" "nat1" {
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public1.id

}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vp1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
}

# Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vp1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id

  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Public Subnet 2 with Public Route Table
resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private Subnet 1 with Private Route Table
resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate Private Subnet 2 with Private Route Table
resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}