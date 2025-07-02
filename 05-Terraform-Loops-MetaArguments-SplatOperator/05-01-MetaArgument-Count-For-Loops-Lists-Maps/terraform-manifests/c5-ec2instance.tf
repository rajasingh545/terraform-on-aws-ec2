# EC2 Instance
resource "aws_instance" "gigznec2vm" {
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type_list[count.index] # Using the first element of the list
  user_data              = file("${path.module}/app1-install.sh")
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  count = 2 # Create two instances using count
  tags = {
    "Name" = "${count.index} Gigzn development EC2 Instance"
  }
}
