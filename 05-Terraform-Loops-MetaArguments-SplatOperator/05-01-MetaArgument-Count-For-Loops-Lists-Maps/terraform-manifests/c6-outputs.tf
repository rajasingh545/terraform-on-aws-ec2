output "for_output_list" {
  description = "List of EC2 Instance Public IPs"
  value       = [for instance in aws_instance.gigznec2vm : instance.public_ip]
}

output "for_output_list_url" {
  description = "List of EC2 Instance Public DNS"
  value       = [for instance in aws_instance.gigznec2vm : instance.public_dns]
}

output "for_output_map" {
  description = "Map of EC2 Instance Public IPs"
  value       = { for instance in aws_instance.gigznec2vm : instance.id => instance.public_ip }
}

output "for_output_map2" {
  description = "Map of EC2 Instance Public DNS"
  value       = { for idx, instance in aws_instance.gigznec2vm : idx => instance.public_dns }
}

output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Operator for EC2 Instance Public DNS"
  value       = aws_instance.gigznec2vm[*].public_dns
}

# SSH Connection Command
output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value = { for instance in aws_instance.gigznec2vm : instance.id => "ssh -i private-key/terraform-key-${random_string.suffix.result}.pem ec2-user@${instance.public_ip}" }
}
