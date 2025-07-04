# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get Route53 Hosted Zone
data "aws_route53_zone" "mydomain" {
  name         = var.domain_name
  private_zone = false
}
