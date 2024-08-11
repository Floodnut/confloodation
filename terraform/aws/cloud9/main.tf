resource aws_cloud9_environment_ec2 "this" {
    name          = var.cloud9.name
    instance_type = var.cloud9.instance_type
    image_id      = var.cloud9.image_id
    subnet_id     = var.cloud9.subnet_id
}

data "aws_instance" "cloud9_instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
        aws_cloud9_environment_ec2.this.id
    ]
  }
}
