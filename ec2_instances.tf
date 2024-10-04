terraform {
backend "s3" {
    bucket         = "kiddcorptf"
    key            = "tf/${var.keyvalue}"
    region         = "us-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    } 
  }
}
variable "keyvalue"{
  type=string
  default="tf"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name="kiddcorp"
  count=3
  tags = {
    Name = "user25-instance-${count.index}",
    role=count.index==0?"user25-lb": (count.index<3?"user25-web":"user25-backend")
  }
}

output "ips"{
  value = aws_instance.instance.*.public_ip
}
