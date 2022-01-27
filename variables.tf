variable "aws_region" {
  type        = string
  description = "AWS region which should be used"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
}

variable "cluster_name" {
  description = "Name of the AWS pihole cluster - will be used to name all created resources"
}

variable "tags" {
  description = "Tags used for the AWS resources created by this template"
  type        = map(string)
}

variable "aws_instance_type" {
  description = "Type of instance"
  default     = "t2.medium"
}

variable "ami_image_id" {
  description = "ID of the AMI image which should be used. If empty, the latest CentOS 7 image will be used. See README.md for AMI image requirements."
  default     = ""
}

variable "ssh_user" {
  description = "Which USER to used for ssh"
  default     = "ubuntu"
}

variable "ssh_private_key" {
  description = "Path to the private part of SSH key which should be used for the instance"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  description = "Path to the public part of SSH key which should be used for the instance"
  default     = "~/.ssh/id_rsa.pub"
}

variable "web_password" {
  description = "Pihole Web Admin password"
  default     = ""
}
