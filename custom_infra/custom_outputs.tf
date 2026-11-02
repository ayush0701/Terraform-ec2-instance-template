output "ec2_instance_public_ips" {
  value = aws_instance.custom_instance[*].public_ip
  description = "this show the Public ip of your ec2 instances"
}