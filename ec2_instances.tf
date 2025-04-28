terraform {
  # backend "s3" {
  #    bucket         = "kiddcorptf"
  #    region         = "us-west-1"
  #  }
backend "s3" {
    bucket         = "kiddcorptf"
    region         = "us-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # assume_role {
  #   role_arn     = "arn:aws:iam::714223118628:role/automation"
  #   session_name = "terraform-session"
  # }
}

data "aws_organizations_organization" "org" {}

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
# resource "aws_key_pair" "key" {
#   key_name   = "my-ec2-keypair"
#   public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
# }

#  resource "aws_instance" "instance" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   key_name = aws_key_pair.key.key_name
#   count=1
#   tags = {
#     Name = "user25-instance-${count.index}",
#     role=count.index==0?"user25-lb": (count.index<3?"user25-web":"user25-backend")
#   }
# }

# output "ips"{
#  value = aws_instance.instance.*.public_ip
# }

locals {
  ids = data.aws_organizations_organization.org.accounts[*].id
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

# Output the list of account IDs
output "account_ids" {
  value = local.ids
}
