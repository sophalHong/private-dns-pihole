# Security Group
data "aws_subnet" "pihole_subnet" {
  id = var.aws_subnet_id
}

resource "aws_security_group" "pihole" {
  vpc_id = data.aws_subnet.pihole_subnet.vpc_id
  name   = var.cluster_name

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags,
  )

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80 
    protocol    = "tcp"
    cidr_blocks = [var.api_access_cidr]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.api_access_cidr]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.api_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM role
resource "aws_iam_policy" "pihole_policy" {
  name        = var.cluster_name
  path        = "/"
  description = "Policy for role ${var.cluster_name}"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*",
          "elasticloadbalancing:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
          ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "pihole_role" {
  name = var.cluster_name
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "pihole-attach" {
  name = "pihole-attachment"
  roles = [aws_iam_role.pihole_role.name]
  policy_arn = aws_iam_policy.pihole_policy.arn
}

resource "aws_iam_instance_profile" "dns_profile" {
  name = var.cluster_name
  role = aws_iam_role.pihole_role.name
}

# Pihole installation script
data "template_file" "script" {
  template = file("${path.module}/pihole_install.sh")

  vars = {
    web_password = var.web_password
  }
}

data "template_cloudinit_config" "install_pihole" {
  gzip = true
  base64_encode = true

  part {
    filename = "pihole-install.sh"
    content_type = "text/x-shellscript"
    content = data.template_file.script.rendered
  }
}

# Keypair
resource "aws_key_pair" "pihole_keypair" {
  key_name = var.cluster_name
  public_key = file(var.ssh_public_key)
}

# EC2 instance
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

resource "aws_instance" "pihole" {
  instance_type = var.aws_instance_type

  ami = length(var.ami_image_id) > 0 ? var.ami_image_id : data.aws_ami.ubuntu.id

  key_name = aws_key_pair.pihole_keypair.key_name

  subnet_id = var.aws_subnet_id

  vpc_security_group_ids = [
    aws_security_group.pihole.id,
  ]

  iam_instance_profile = aws_iam_instance_profile.dns_profile.name

  user_data = data.template_cloudinit_config.install_pihole.rendered

  provisioner "local-exec" {
    command = "sudo cloud-init status --wait"
  }
  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags,
  )
}

resource "null_resource" "pihole-installation" {
  depends_on = [aws_instance.pihole]
  connection {
    host        = aws_instance.pihole.public_ip
    user        = var.ssh_user
    type        = "ssh"
    private_key = file(var.ssh_private_key)
    agent       = false
    timeout     = "300s"
  }
  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c \"timeout 300 sed '\\/tmp\\/finished-user-data/q' <(tail -f /var/log/cloud-init-output.log)\""
    ]
  }
}
