# AWS SES (Simple Email Service) Configuration using Terraform

This directory contains Terraform configurations for setting up AWS Simple Email Service (SES) with comprehensive email sending capabilities, domain verification, DKIM authentication, and monitoring.

## Features

- **Domain Identity Verification**: Automatically verifies domain ownership
- **Email Identity Verification**: Verifies individual email addresses
- **DKIM Authentication**: Sets up DomainKeys Identified Mail for better deliverability
- **Mail From Domain**: Configures custom mail-from domain for better reputation
- **Configuration Sets**: Manages email sending configuration and tracking
- **SNS Notifications**: Sets up bounce, complaint, and delivery notifications
- **IAM Roles and Policies**: Creates necessary IAM resources for email sending
- **SMTP Credentials**: Generates SMTP user and credentials for application integration
- **Route53 Integration**: Automatically creates DNS records for verification and authentication

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS SES Configuration                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Domain Identity │  │ Email Identities │  │ Configuration   │  │
│  │  + Verification  │  │  + Verification  │  │     Set         │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  DKIM Setup     │  │  Mail From      │  │ SNS Topics      │  │
│  │  + DNS Records  │  │  Domain + SPF   │  │  + Policies     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  IAM Roles &    │  │  SMTP User &    │  │ Route53 DNS     │  │
│  │  Policies       │  │  Credentials    │  │  Records        │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.6)
3. **Route53 Hosted Zone** for your domain (must exist before running)
4. **Domain ownership** - You must own the domain you're configuring

## Files Structure

```
terraform-manifests/
├── c1-versions.tf              # Terraform and provider versions
├── c2-generic-variables.tf     # Input variables
├── c3-local-values.tf          # Local values and tags
├── c4-ses-domain-identity.tf   # Domain identity and DKIM setup
├── c5-ses-configuration-set.tf # Configuration set and event destinations
├── c6-sns-topics.tf            # SNS topics for notifications
├── c7-datasources.tf           # Data sources (AWS account, region, Route53)
├── c8-iam-ses-roles.tf         # IAM roles, policies, and SMTP user
├── c9-outputs.tf               # Output values
└── terraform.tfvars            # Variable values
```

## Configuration Steps

### 1. Update Variables

Edit `terraform.tfvars` with your specific values:

```hcl
# Generic Variables
aws_region         = "us-east-1"
environment        = "dev"
business_division  = "SAP"

# SES Specific Variables
domain_name               = "yourdomain.com"  # Replace with your actual domain
email_addresses           = ["admin@yourdomain.com", "noreply@yourdomain.com"]
from_email               = "noreply@yourdomain.com"
configuration_set_name   = "my-configuration-set"
enable_sns_notifications = true
sns_bounce_topic_name    = "ses-bounce-notifications"
sns_complaint_topic_name = "ses-complaint-notifications"
enable_dkim              = true
enable_mail_from_domain  = true
mail_from_subdomain      = "mail"
```

### 2. Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan
```

### 3. Apply Configuration

```bash
# Apply the configuration
terraform apply
```

### 4. Verify Setup

After successful deployment, verify:

1. **Domain Verification**: Check AWS SES console for domain verification status
2. **Email Verification**: Verify individual email addresses via confirmation emails
3. **DNS Records**: Confirm Route53 records are created correctly
4. **SNS Subscriptions**: Check and confirm SNS subscription emails

## DNS Records Created

The configuration automatically creates the following DNS records:

### Domain Verification
- **Type**: TXT
- **Name**: `_amazonses.yourdomain.com`
- **Value**: Verification token from SES

### DKIM Records (3 records)
- **Type**: CNAME
- **Name**: `{token}._domainkey.yourdomain.com`
- **Value**: `{token}.dkim.amazonses.com`

### Mail From Domain
- **MX Record**: `mail.yourdomain.com` → `10 feedback-smtp.region.amazonses.com`
- **TXT Record**: `mail.yourdomain.com` → `v=spf1 include:amazonses.com ~all`

## Output Values

The configuration provides the following outputs:

- **SES Domain Identity ARN**: For referencing the domain
- **DKIM Tokens**: For manual DNS configuration if needed
- **SMTP Credentials**: Access key and secret for application integration
- **SMTP Endpoint**: Email server endpoint for your region
- **SNS Topic ARNs**: For additional notification integrations
- **IAM Role ARNs**: For EC2 instance profiles or other services

## Usage Examples

### Using SMTP Credentials in Applications

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Use outputs from Terraform
SMTP_SERVER = "email-smtp.us-east-1.amazonaws.com"
SMTP_PORT = 587
USERNAME = "your-smtp-username"  # From Terraform output
PASSWORD = "your-smtp-password"  # From Terraform output

def send_email(to_email, subject, body):
    msg = MIMEMultipart()
    msg['From'] = "noreply@yourdomain.com"
    msg['To'] = to_email
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body, 'plain'))
    
    server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    server.starttls()
    server.login(USERNAME, PASSWORD)
    server.send_message(msg)
    server.quit()
```

### Using AWS SDK

```python
import boto3
from botocore.exceptions import ClientError

def send_email_aws_sdk(to_email, subject, body):
    client = boto3.client('ses', region_name='us-east-1')
    
    try:
        response = client.send_email(
            Source='noreply@yourdomain.com',
            Destination={'ToAddresses': [to_email]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body}}
            },
            ConfigurationSetName='my-configuration-set'
        )
        return response['MessageId']
    except ClientError as e:
        print(f"Error: {e}")
        return None
```

## Monitoring and Troubleshooting

### SNS Notifications
- **Bounce notifications**: Delivered to configured SNS topic
- **Complaint notifications**: Delivered to configured SNS topic
- **Delivery notifications**: Delivered to configured SNS topic

### Common Issues

1. **Domain Verification Pending**: Check if DNS records are properly configured
2. **DKIM Verification Failed**: Verify all 3 DKIM CNAME records are created
3. **Emails not sending**: Check SES sending limits and account status
4. **High bounce rate**: Review email list quality and implement proper list management

### Monitoring Commands

```bash
# Check SES sending statistics
aws ses get-send-statistics --region us-east-1

# Check domain verification status
aws ses get-identity-verification-attributes --identities yourdomain.com --region us-east-1

# Check DKIM verification status
aws ses get-identity-dkim-attributes --identities yourdomain.com --region us-east-1
```

## Security Considerations

1. **SMTP Credentials**: Store securely using AWS Secrets Manager or similar
2. **IAM Roles**: Use least privilege principle
3. **SNS Topics**: Ensure proper access controls
4. **Email Validation**: Implement proper email validation in applications
5. **Rate Limiting**: Implement rate limiting to avoid hitting SES limits

## Cost Optimization

- **Free Tier**: 62,000 emails/month for the first 12 months
- **Pricing**: $0.10 per 1,000 emails after free tier
- **Data Transfer**: Additional charges for data transfer
- **Monitoring**: SNS notifications incur minimal charges

## Cleanup

To remove all resources:

```bash
terraform destroy
```

**Note**: This will remove all SES configurations, IAM roles, and DNS records. Ensure you have backups of any important configurations.

## Support

For issues and questions:
1. Check AWS SES documentation
2. Review Terraform AWS provider documentation
3. Check AWS SES service limits and quotas
4. Review CloudWatch logs for detailed error messages

## Version History

- **v1.0**: Initial SES configuration with domain verification, DKIM, and monitoring
- **v1.1**: Added mail-from domain configuration
- **v1.2**: Enhanced IAM roles and SMTP user management
