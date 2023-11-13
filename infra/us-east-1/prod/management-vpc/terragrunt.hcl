# terraform.tf

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "management_vpc" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Management-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count               = 2
  vpc_id              = aws_vpc.management_vpc.id
  cidr_block          = cidrsubnet(aws_vpc.management_vpc.cidr_block, 4, count.index * 4)
  availability_zone   = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "management-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "management_igw" {
  vpc_id = aws_vpc.management_vpc.id
}

resource "aws_route_table" "public_route_table" {
  count = 2
  vpc_id = aws_vpc.management_vpc.id
}

resource "aws_route" "public_route" {
  count                 = 2
  route_table_id        = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = aws_internet_gateway.management_igw.id
}

resource "aws_subnet_route_table_association" "public_route_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

# VPC Peering Configuration
#resource "aws_vpc_peering_connection" "peering" {
#  peer_vpc_id = "vpc-099d582f5470a11f3" # Existing VPC ID which is EKS VPC
#  vpc_id      = aws_vpc.management_vpc.id
#}

#resource "aws_vpc_peering_connection_accepter" "accepter" {
#  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
# auto_accept              = true
#}

# New route for VPC peering connection
#resource "aws_route" "eks_vpc_route" {
#  route_table_id            = aws_route_table.public_route_table[0].id # Use the desired route table ID
# destination_cidr_block    = "10.30.0.0/16"
# vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
#}

output "vpc_id" {
  value = aws_vpc.management_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
