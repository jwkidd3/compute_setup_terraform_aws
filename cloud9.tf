terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    } 
  }
}

variable "users" {
  type    = map(number)
  default = {
    "user" = 2
  }
}
locals {
  expanded_names = {
    for name, count in var.users : name => [
      for i in range(1,20,1) : format("%s%01d", name, i)
    ]
  }
}
data "aws_iam_user" "user_data" {
  for_each = toset(local.expanded_names.user)
  user_name = each.key
}
output "the_users"{
  value = local.expanded_names
}
output "all_arns" {
  value       = values(data.aws_iam_user.user_data)[*].arn
}
output "number_users"{
  value = length(local.expanded_names.user)
}
resource "aws_cloud9_environment_ec2" "example" {
  count=length(local.expanded_names.user)
  instance_type = "m5.large"
  name          = "example-env-${count.index + 1}"
  image_id      = "ubuntu-18.04-x86_64"
  owner_arn    = values(data.aws_iam_user.user_data)[count.index].arn
}
