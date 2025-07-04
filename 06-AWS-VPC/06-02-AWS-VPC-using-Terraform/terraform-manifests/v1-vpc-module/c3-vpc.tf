# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0.1"
  name    = "my-gigzn-dev-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  #database subnet
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  #   create_database_nat_gateway_route      = true
  #   create_database_internet_gateway_route = true
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "gigzn-dev-public-subnet"
    Type = "Public"
  }

  private_subnet_tags = {
    Name = "gigzn-dev-private-subnet"
    Type = "Private"
  }

  database_subnet_tags = {
    Name = "gigzn-dev-database-subnet"
    Type = "Database"
  }

  nat_gateway_tags = {
    Name = "gigzn-dev-nat-gateway"
    Type = "NAT Gateway"
  }

  igw_tags = {
    Name = "gigzn-dev-internet-gateway"
    Type = "Internet Gateway"
  }

  public_route_table_tags = {
    Name = "gigzn-dev-public-route-table"
    Type = "Public Route Table"
  }

  private_route_table_tags = {
    Name = "gigzn-dev-private-route-table"
    Type = "Private Route Table"
  }

  database_route_table_tags = {
    Name = "gigzn-dev-database-route-table"
    Type = "Database Route Table"
  }

  vpc_tags = {
    Name = "gigzn-dev-vpc"
    Type = "VPC"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Gigzn"
  }
}
