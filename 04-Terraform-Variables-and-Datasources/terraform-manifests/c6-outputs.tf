# Terraform Output Values

# EC2 Instance Public IP
output "instance_publicip" {
  description = "EC2 Instance Public IP"
  value = aws_instance.gigznec2vm.public_ip
}

# EC2 Instance Public DNS
output "instance_publicdns" {
  description = "EC2 Instance Public DNS"
  value = aws_instance.gigznec2vm.public_dns
}

# SSH Connection Command
output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value = "ssh -i private-key/terraform-key-${random_string.suffix.result}.pem ec2-user@${aws_instance.gigznec2vm.public_ip}"
}
