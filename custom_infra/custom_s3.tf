resource "aws_s3_bucket" "custom_app_bucket" {
    bucket = "${var.custom_env}-app-bucket-test-ayu"
    tags = {
        Name = "${var.custom_env}-app-bucket-test-ayu"
        environment = var.custom_env
    }
}