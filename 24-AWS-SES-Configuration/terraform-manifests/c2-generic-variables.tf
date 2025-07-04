# Input Variables
# AWS Region
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

# Business Division
variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "SAP"
}

# Domain Name for SES
variable "domain_name" {
  description = "Domain name for SES email configuration"
  type        = string
  default     = "gigzn.com"
}

# Email addresses for SES
variable "email_addresses" {
  description = "List of email addresses to verify for SES"
  type        = list(string)
  default     = ["hello@chennaifreelancers.in", "rajasingh545@gmail.com", "support@gigzn.com"]
}

# Email From Address
variable "from_email" {
  description = "From email address for SES"
  type        = string
  default     = "noreply@gigzn.com"
}

# Configuration Set Name
variable "configuration_set_name" {
  description = "Name of the SES configuration set"
  type        = string
  default     = "default-configuration-set"
}

# Enable SNS bounce/complaint notifications
variable "enable_sns_notifications" {
  description = "Enable SNS notifications for bounces and complaints"
  type        = bool
  default     = true
}

# SNS Topic Name for Bounces
variable "sns_bounce_topic_name" {
  description = "SNS topic name for bounce notifications"
  type        = string
  default     = "ses-bounce-notifications"
}

# SNS Topic Name for Complaints
variable "sns_complaint_topic_name" {
  description = "SNS topic name for complaint notifications"
  type        = string
  default     = "ses-complaint-notifications"
}

# Enable DKIM
variable "enable_dkim" {
  description = "Enable DKIM for domain"
  type        = bool
  default     = true
}

# Enable mail from domain
variable "enable_mail_from_domain" {
  description = "Enable mail from domain for better deliverability"
  type        = bool
  default     = true
}

# Mail from subdomain
variable "mail_from_subdomain" {
  description = "Subdomain for mail from domain"
  type        = string
  default     = "mail"
}
