# SES Domain Identity
resource "aws_ses_domain_identity" "domain" {
  domain = var.domain_name
}

# SES Domain Identity Verification
resource "aws_ses_domain_identity_verification" "domain_verification" {
  domain     = aws_ses_domain_identity.domain.id
  depends_on = [aws_route53_record.ses_verification_record]
  
  timeouts {
    create = "5m"
  }
}

# Route53 Record for SES Domain Verification
resource "aws_route53_record" "ses_verification_record" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain.verification_token]
}

# SES Domain DKIM Configuration
resource "aws_ses_domain_dkim" "domain_dkim" {
  count  = var.enable_dkim ? 1 : 0
  domain = aws_ses_domain_identity.domain.domain
}

# Route53 Records for DKIM
resource "aws_route53_record" "dkim_record" {
  count   = var.enable_dkim ? 3 : 0
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.domain_dkim[0].dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# SES Email Identity (Individual Email Addresses)
resource "aws_ses_email_identity" "email" {
  count = length(var.email_addresses)
  email = var.email_addresses[count.index]
}

# SES Mail From Domain
resource "aws_ses_domain_mail_from" "mail_from" {
  count            = var.enable_mail_from_domain ? 1 : 0
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain_name}"
}

# Route53 MX Record for Mail From Domain
resource "aws_route53_record" "mail_from_mx" {
  count   = var.enable_mail_from_domain ? 1 : 0
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "${var.mail_from_subdomain}.${var.domain_name}"
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

# Route53 TXT Record for Mail From Domain SPF
resource "aws_route53_record" "mail_from_txt" {
  count   = var.enable_mail_from_domain ? 1 : 0
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "${var.mail_from_subdomain}.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}
