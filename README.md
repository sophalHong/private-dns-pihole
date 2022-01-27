# Amazon AWS Pihole 

This Terraform configuration creates:
* Amazon AWS VPC
* Public Subnet and Internet Gateway
* Amazon EC2 instance
* Execute cloud-init/user_data to run Pihole installation

<!-- TOC -->

- [Amazon AWS VPC](#amazon-aws-vpc)
    - [Prerequisites and dependencies](#prerequisites-and-dependencies)
    - [Configuration](#configuration)
    - [Creating the AWS Pihole](#creating-the-aws-pihole)
    - [Deleting the AWS Pihole](#deleting-the-aws-pihole)

<!-- /TOC -->

## Prerequisites and dependencies

There are no other dependencies apart from [Terraform](https://www.terraform.io).

## Configuration

| Option | Explanation | Example |
|--------|-------------|---------|
| `aws_region` | AWS region which should be used | `ap-northeast-1` |
| `vpc_name` | Name of the VPC which should ve created | `my-vpc` |
| `vpc_cidr` | CIDR address which should be used | `10.0.0.0/16` |
| `cluster_name` | Name of the AWS Pihole cluster | "my-pihole" |
| `aws_instance_type` | Type of EC2 Instance | "t2.medium" |
| `ssh_public_key` | Path to the pulic part of SSH key, used for the instance | "~/.ssh/id_rsa.pub" |
| `ssh_private_key` | Path to the private part of SSH key, used for the instance | "~/.ssh/id_rsa" |
| `ami_image_id` | ID of the AMI image. If empty, default ubuntu 20.04 image is used | "ami-063c5a5e375b71d95" |
| `tags` | Tags which should be applied to all resources | `{ Application = "Pihole" }` |

## Creating the AWS Pihole

To create the VPC, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Apply Terraform configuration:
```bash
terraform init
terraform apply
# terraform apply -auto-approve
```

## Deleting the AWS Pihole

To delete the VPC, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Destroy Terraform configuration:
```bash
terraform destroy
```
