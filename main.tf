terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}
data "aws_ssm_parameter" "windows" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "lab" {
  name_prefix = "uvu-cyber-lab-"
  description = "No inbound traffic; outbound for updates and SSM"
  vpc_id      = data.aws_vpc.default.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Project = "uvu-cyber-lab" }
}

locals {
  instances = {
    ubuntu  = { ami = data.aws_ssm_parameter.ubuntu.value, type = var.linux_instance_type }
    windows = { ami = data.aws_ssm_parameter.windows.value, type = var.windows_instance_type }
    kali    = { ami = var.kali_ami_id, type = var.linux_instance_type }
  }
}

resource "aws_instance" "lab" {
  for_each                    = local.instances
  ami                         = each.value.ami
  instance_type               = each.value.type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.lab.id]
  associate_public_ip_address = false
  root_block_device {
    volume_type = "gp3"
    volume_size = each.key == "windows" ? 50 : 30
    encrypted   = true
  }
  tags = {
    Name    = "${each.key}-uvu-${var.course_id}-${var.student_id}"
    Project = "uvu-cyber-lab"
    OS      = each.key
  }
}
