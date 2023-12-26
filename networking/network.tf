# VPC for network
resource "aws_vpc" "company_network_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My Company's network VPC"
  }
}

# SUBNET for network
resource "aws_subnet" "company_network_subnetwork" {
  vpc_id     = aws_vpc.company_network_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "My Company's network Subnet"
  }
}

# Internet GateWay
resource "aws_internet_gateway" "company_network_gw" {
  vpc_id = aws_vpc.company_network_vpc.id

  tags = {
    Name = "My Company's network Internet Gateway"
  }
}

#Network ACL
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.company_network_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow" #Could be allow also o
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "main"
  }
}

# Route table
resource "aws_route_table" "company_network_route_table" {
  vpc_id = aws_vpc.company_network_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.company_network_gw.id
  }

  tags = {
    Name = "My Company's network Route Table"
  }
}

# Route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.company_network_subnetwork.id
  route_table_id = aws_route_table.company_network_route_table.id
}

# Security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.company_network_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.company_network_vpc.cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.company_network_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# Outputs eqv
output "aws_vpc" {
  value = aws_vpc.company_network_vpc.id
}

output "aws_subnet" {
  value = aws_subnet.company_network_subnetwork.id
}

output "aws_gw" {
  value = aws_internet_gateway.company_network_gw.id
}

output "aws_route_table" {
  value = aws_route_table.company_network_route_table.id
}

output "aws_security_group" {
  value = aws_security_group.allow_tls.id
}