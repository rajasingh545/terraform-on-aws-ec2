# terraform.tfvars
# Generic Variables
aws_region         = "ap-south-1"
environment        = "dev"
business_division  = "SAP"

# SES Specific Variables
domain_name               = "gigzn.com"  # Replace with your actual domain
email_addresses           = ["hello@chennaifreelancers.in", "rajasingh545@gmail.com", "support@gigzn.com"]  # Replace with your actual email addresses
from_email               = "noreply@gigzn.com"  # Replace with your actual from email
configuration_set_name   = "my-configuration-set"
enable_sns_notifications = true
sns_bounce_topic_name    = "ses-bounce-notifications"
sns_complaint_topic_name = "ses-complaint-notifications"
enable_dkim              = true
enable_mail_from_domain  = true
mail_from_subdomain      = "mail"
