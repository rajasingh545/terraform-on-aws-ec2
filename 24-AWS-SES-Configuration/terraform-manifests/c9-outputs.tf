# Terraform Output Values

# SES Domain Identity
output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.domain.arn
}

output "ses_domain_identity_verification_token" {
  description = "SES domain identity verification token"
  value       = aws_ses_domain_identity.domain.verification_token
}

# SES DKIM Tokens
output "ses_dkim_tokens" {
  description = "SES DKIM tokens"
  value       = var.enable_dkim ? aws_ses_domain_dkim.domain_dkim[0].dkim_tokens : []
}

# SES Configuration Set
output "ses_configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = aws_ses_configuration_set.configuration_set.name
}

output "ses_configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = aws_ses_configuration_set.configuration_set.arn
}

# SNS Topics
output "sns_bounce_topic_arn" {
  description = "ARN of the SNS bounce topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.bounce_topic[0].arn : null
}

output "sns_complaint_topic_arn" {
  description = "ARN of the SNS complaint topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.complaint_topic[0].arn : null
}

output "sns_delivery_topic_arn" {
  description = "ARN of the SNS delivery topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.delivery_topic[0].arn : null
}

# IAM Role and Policy
output "ses_sending_role_arn" {
  description = "ARN of the SES sending IAM role"
  value       = aws_iam_role.ses_sending_role.arn
}

output "ses_sending_policy_arn" {
  description = "ARN of the SES sending IAM policy"
  value       = aws_iam_policy.ses_sending_policy.arn
}

output "ses_instance_profile_arn" {
  description = "ARN of the SES IAM instance profile"
  value       = aws_iam_instance_profile.ses_instance_profile.arn
}

# SMTP Credentials
output "ses_smtp_user_name" {
  description = "Name of the SES SMTP user"
  value       = aws_iam_user.ses_smtp_user.name
}

output "ses_smtp_access_key_id" {
  description = "Access key ID for SES SMTP user"
  value       = aws_iam_access_key.ses_smtp_user_key.id
}

output "ses_smtp_secret_access_key" {
  description = "Secret access key for SES SMTP user"
  value       = aws_iam_access_key.ses_smtp_user_key.secret
  sensitive   = true
}

# SES SMTP Endpoint
output "ses_smtp_endpoint" {
  description = "SES SMTP endpoint"
  value       = "email-smtp.${var.aws_region}.amazonaws.com"
}

# SES SMTP Port
output "ses_smtp_port" {
  description = "SES SMTP port"
  value       = "587"
}

# Email Addresses
output "verified_email_addresses" {
  description = "List of verified email addresses"
  value       = var.email_addresses
}

# Domain Information
output "domain_name" {
  description = "Domain name configured for SES"
  value       = var.domain_name
}

output "mail_from_domain" {
  description = "Mail from domain"
  value       = var.enable_mail_from_domain ? "${var.mail_from_subdomain}.${var.domain_name}" : null
}

# Route53 Records Information
output "route53_verification_record" {
  description = "Route53 verification record for SES domain"
  value = {
    name   = "_amazonses.${var.domain_name}"
    type   = "TXT"
    value  = aws_ses_domain_identity.domain.verification_token
  }
}

output "route53_dkim_records" {
  description = "Route53 DKIM records for SES domain"
  value = var.enable_dkim ? [
    for i in range(3) : {
      name  = "${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[i]}._domainkey.${var.domain_name}"
      type  = "CNAME"
      value = "${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[i]}.dkim.amazonses.com"
    }
  ] : []
}

output "route53_mail_from_records" {
  description = "Route53 records for mail from domain"
  value = var.enable_mail_from_domain ? {
    mx_record = {
      name   = "${var.mail_from_subdomain}.${var.domain_name}"
      type   = "MX"
      value  = "10 feedback-smtp.${var.aws_region}.amazonses.com"
    }
    txt_record = {
      name   = "${var.mail_from_subdomain}.${var.domain_name}"
      type   = "TXT"
      value  = "v=spf1 include:amazonses.com ~all"
    }
  } : null
}
