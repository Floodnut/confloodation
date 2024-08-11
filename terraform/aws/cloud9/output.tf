output "cloud9_url" {
  value = "https://${var.cloud9.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.this.id}"
}

output "cloud9_name" {
  value = aws_cloud9_environment_ec2.this.name
}