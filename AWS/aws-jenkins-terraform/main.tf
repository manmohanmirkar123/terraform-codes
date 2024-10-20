terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "jenkinsvpc" {
  cidr_block = "10.0.0.0/16"
   
    tags = {
        Name = "prod-vpc"
    }
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "terraform_ec2_key"
  public_key = file("terraform_ec2_key.pub")
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.jenkinsvpc.id
  map_public_ip_on_launch = "true"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}
 resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow Jenkins Traffic"
  #vpc_id      = aws_vpc.jenkinsvpc.id

  ingress {
    description      = "Allow from Personal CIDR block"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SSH from Personal CIDR block"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Jenkins SG"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}
resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t3.medium"
  key_name        = aws_key_pair.terraform_ec2_key.key_name
  security_groups = [aws_security_group.jenkins_sg.name]
  #security_groups = [aws_security_group.jenkins_sg.name]
  user_data       = <<EOF
  #!/bin/bash

amazon-linux-extras install epel -y
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install java-17-amazon-corretto -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
sudo systemctl daemon-reload

  EOF
  tags = {
    Name = "Jenkins"
  }
}

