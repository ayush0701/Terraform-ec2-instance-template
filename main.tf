#file tells you how to call the modules 

module "dev-infra" {
  source = "./custom_infra"
  custom_env = "dev"
  custom_ec2_count = 1
  custom_ec2_ami = "ami-038a727c6c8b5450a"
  custom_ec2_instance_type = "t3.micro"
}

module "stagging-infra" {
  source = "./custom_infra"
  custom_env = "staging"
  custom_ec2_count = 1
  custom_ec2_ami = "ami-038a727c6c8b5450a"
  custom_ec2_instance_type = "t3.small"
}

module "prod-infra" {
  source = "./custom_infra"
  custom_env = "prod"
  custom_ec2_count = 1
  custom_ec2_ami = "ami-038a727c6c8b5450a"
  custom_ec2_instance_type = "t3.medium"
}