# Define Local Values in Terraform
locals {
  owners      = var.business_division
  environment = var.environment
  name        = "${var.business_division}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  ses_tags = {
    Name        = "${local.name}-ses"
    Environment = local.environment
    Owner       = local.owners
    Service     = "SES"
  }
}
