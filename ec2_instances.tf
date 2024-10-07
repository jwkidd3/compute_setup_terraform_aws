terraform {
backend "s3" {
    bucket         = "kiddcorptf"
    region         = "us-west-1"
  }
# pass the key on init -backend-config="key=terraform/state/dev.tfstate"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    } 
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

variable "student_alias"{
  description="your student alias"
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
    Name = "${var.student_alias}-${count.index}",
    role=count.index==0?"user25-lb": (count.index<3?"user25-web":"user25-backend") 
  }
}

output "ips"{
  value = aws_instance.instance.*.public_ip
}
