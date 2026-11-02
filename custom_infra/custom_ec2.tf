# Key Pair
resource "aws_key_pair" "custom_key_pair" {
  key_name   = "${var.custom_env}terra-automate-key-josh"
  public_key = file("${path.module}/terra-automate-key.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {}

# Security Group
resource "aws_security_group" "custom_security_group" {
  name        = "${var.custom_env}terra-security-group"
  vpc_id      = aws_default_vpc.default.id # interpolation
  description = "Inbound and outbound rules for the instance security group"
}

# Inbound & Outbound rules
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.custom_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.custom_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.custom_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols and ports
}

# EC2 Instances
resource "aws_instance" "custom_instance" {
  count = var.custom_ec2_count

  ami           = var.custom_ec2_ami # verify this exists in us-west-2
  instance_type = var.custom_ec2_instance_type

  key_name               = aws_key_pair.custom_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.custom_security_group.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.custom_env}app-ec2-server-${count.index}"
    environment = var.custom_env
  }
}