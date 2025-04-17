terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }

    required_version = ">= 1.2.0" 
}


provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ExampleVPC"
  }
}

resource "aws_subnet" "example_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.example_vpc.id
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ExampleSubnet"
  }
}


resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "ExampleIGW"
  }
}

resource "aws_route_table" "example_rt" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    Name = "ExampleRouteTable"
  }
}


resource "aws_route_table_association" "example_rta" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_rt.id
}

resource "aws_instance" "app_server" {
  ami           = "ami-034bc4e4fcccfe844"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSecurityGroup"
  }
}
