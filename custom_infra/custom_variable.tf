variable "custom_env" {
  type = string
  description = "type of environment wanted to create"
}
variable "custom_ec2_count" {
  type = number
  description = "count for ec2 instances"
}

variable "custom_ec2_ami" {
  type = string
  description = "ami for ec2 instances"
}

variable "custom_ec2_instance_type" {
  type = string
  description = "instance type for ec2 instance"
}