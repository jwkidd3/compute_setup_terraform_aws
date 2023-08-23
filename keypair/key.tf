terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "specify your region"
}

resource "aws_key_pair" "deployer" {
  key_name   = "<add your username>_deployer-key"
  public_key =file("~/.ssh/id_rsa.pub") 
    
}
