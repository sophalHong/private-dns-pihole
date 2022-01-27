terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./modules/vpc"

  aws_zones       = data.aws_availability_zones.available.names
  aws_region      = var.aws_region
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr

  ## Tags
  tags = var.tags
}

module "pihole" {
  source = "./modules/pihole"

  aws_subnet_id        = module.vpc.subnet_id
  aws_region           = var.aws_region
  cluster_name         = var.cluster_name
  aws_instance_type    = var.aws_instance_type
  ssh_private_key      = var.ssh_private_key
  ssh_public_key       = var.ssh_public_key
  ssh_user             = var.ssh_user
  ami_image_id         = var.ami_image_id
  web_password         = var.web_password
  tags                 = var.tags
}
