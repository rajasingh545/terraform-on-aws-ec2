# Create a new Key Pair
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key-${random_string.suffix.result}"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Generate random suffix to ensure unique key name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Generate private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file
resource "local_file" "terraform_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "private-key/terraform-key-${random_string.suffix.result}.pem"
  file_permission = "0400"
}
