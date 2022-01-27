### AWS VPC setting
aws_region      = "ap-northeast-1"
vpc_name        = "dns-vpc"
vpc_cidr        = "10.0.0.0/16"

### EC2 instance setting
cluster_name      = "my-dns"
aws_instance_type = "t2.medium"
ssh_private_key   = "~/.ssh/id_rsa"
ssh_public_key    = "~/.ssh/id_rsa.pub"
ssh_user          = "centos"
ami_image_id      = "ami-063c5a5e375b71d95" # Centos Linux 8.4.2105
web_password      = "myPassword"
tags = {
  Application     = "DNS_Pihole"
}
