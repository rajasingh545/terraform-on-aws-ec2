# Sample Application Integration with AWS SES

This directory contains sample code demonstrating how to integrate with the AWS SES configuration created by Terraform.

## Python Email Sending Example

```python
import boto3
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import json
from botocore.exceptions import ClientError

class SESEmailSender:
    def __init__(self, region='us-east-1', configuration_set=None):
        self.ses_client = boto3.client('ses', region_name=region)
        self.configuration_set = configuration_set
        
    def send_simple_email(self, from_email, to_emails, subject, body_text, body_html=None):
        """
        Send a simple email using AWS SES SendEmail API
        """
        try:
            # Prepare the email message
            message = {
                'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                'Body': {'Text': {'Data': body_text, 'Charset': 'UTF-8'}}
            }
            
            if body_html:
                message['Body']['Html'] = {'Data': body_html, 'Charset': 'UTF-8'}
            
            # Send the email
            response = self.ses_client.send_email(
                Source=from_email,
                Destination={'ToAddresses': to_emails},
                Message=message,
                ConfigurationSetName=self.configuration_set
            )
            
            return {
                'success': True,
                'message_id': response['MessageId'],
                'response': response
            }
            
        except ClientError as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': e.response['Error']['Code']
            }
    
    def send_templated_email(self, from_email, to_emails, template_name, template_data):
        """
        Send a templated email using AWS SES SendTemplatedEmail API
        """
        try:
            response = self.ses_client.send_templated_email(
                Source=from_email,
                Destination={'ToAddresses': to_emails},
                Template=template_name,
                TemplateData=json.dumps(template_data),
                ConfigurationSetName=self.configuration_set
            )
            
            return {
                'success': True,
                'message_id': response['MessageId'],
                'response': response
            }
            
        except ClientError as e:
            return {
                'success': False,
                'error': str(e),
                'error_code': e.response['Error']['Code']
            }


class SMTPEmailSender:
    def __init__(self, smtp_server, smtp_port, username, password):
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.username = username
        self.password = password
    
    def send_email(self, from_email, to_emails, subject, body_text, body_html=None, attachments=None):
        """
        Send email using SMTP
        """
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['From'] = from_email
            msg['To'] = ', '.join(to_emails)
            msg['Subject'] = subject
            
            # Add text part
            text_part = MIMEText(body_text, 'plain', 'utf-8')
            msg.attach(text_part)
            
            # Add HTML part if provided
            if body_html:
                html_part = MIMEText(body_html, 'html', 'utf-8')
                msg.attach(html_part)
            
            # Add attachments if provided
            if attachments:
                for file_path in attachments:
                    with open(file_path, 'rb') as f:
                        part = MIMEBase('application', 'octet-stream')
                        part.set_payload(f.read())
                        encoders.encode_base64(part)
                        part.add_header(
                            'Content-Disposition',
                            f'attachment; filename= {file_path.split("/")[-1]}'
                        )
                        msg.attach(part)
            
            # Send email
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.username, self.password)
            server.send_message(msg)
            server.quit()
            
            return {'success': True, 'message': 'Email sent successfully'}
            
        except Exception as e:
            return {'success': False, 'error': str(e)}


# Example usage
def main():
    # Configuration from Terraform outputs
    AWS_REGION = 'us-east-1'
    CONFIGURATION_SET = 'my-configuration-set'
    FROM_EMAIL = 'noreply@yourdomain.com'
    
    # SMTP Configuration (from Terraform outputs)
    SMTP_SERVER = 'email-smtp.us-east-1.amazonaws.com'
    SMTP_PORT = 587
    SMTP_USERNAME = 'your-smtp-access-key-id'  # From Terraform output
    SMTP_PASSWORD = 'your-smtp-secret-key'     # From Terraform output
    
    # Example 1: Using SES API
    ses_sender = SESEmailSender(region=AWS_REGION, configuration_set=CONFIGURATION_SET)
    
    result = ses_sender.send_simple_email(
        from_email=FROM_EMAIL,
        to_emails=['recipient@example.com'],
        subject='Test Email from SES',
        body_text='This is a test email sent using AWS SES API.',
        body_html='<html><body><h1>Test Email</h1><p>This is a test email sent using AWS SES API.</p></body></html>'
    )
    
    if result['success']:
        print(f"Email sent successfully! Message ID: {result['message_id']}")
    else:
        print(f"Failed to send email: {result['error']}")
    
    # Example 2: Using SMTP
    smtp_sender = SMTPEmailSender(SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD)
    
    result = smtp_sender.send_email(
        from_email=FROM_EMAIL,
        to_emails=['recipient@example.com'],
        subject='Test Email from SMTP',
        body_text='This is a test email sent using SMTP.',
        body_html='<html><body><h1>Test Email</h1><p>This is a test email sent using SMTP.</p></body></html>'
    )
    
    if result['success']:
        print("SMTP email sent successfully!")
    else:
        print(f"Failed to send SMTP email: {result['error']}")


if __name__ == "__main__":
    main()
```

## Node.js Email Sending Example

```javascript
const AWS = require('aws-sdk');
const nodemailer = require('nodemailer');

// Configure AWS SDK
AWS.config.update({
    region: 'us-east-1'
});

const ses = new AWS.SES();

class SESEmailSender {
    constructor(configurationSet = null) {
        this.configurationSet = configurationSet;
    }

    async sendSimpleEmail(fromEmail, toEmails, subject, bodyText, bodyHtml = null) {
        const params = {
            Source: fromEmail,
            Destination: {
                ToAddresses: toEmails
            },
            Message: {
                Subject: {
                    Data: subject,
                    Charset: 'UTF-8'
                },
                Body: {
                    Text: {
                        Data: bodyText,
                        Charset: 'UTF-8'
                    }
                }
            }
        };

        if (bodyHtml) {
            params.Message.Body.Html = {
                Data: bodyHtml,
                Charset: 'UTF-8'
            };
        }

        if (this.configurationSet) {
            params.ConfigurationSetName = this.configurationSet;
        }

        try {
            const result = await ses.sendEmail(params).promise();
            return {
                success: true,
                messageId: result.MessageId,
                response: result
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                errorCode: error.code
            };
        }
    }

    async sendTemplatedEmail(fromEmail, toEmails, templateName, templateData) {
        const params = {
            Source: fromEmail,
            Destination: {
                ToAddresses: toEmails
            },
            Template: templateName,
            TemplateData: JSON.stringify(templateData)
        };

        if (this.configurationSet) {
            params.ConfigurationSetName = this.configurationSet;
        }

        try {
            const result = await ses.sendTemplatedEmail(params).promise();
            return {
                success: true,
                messageId: result.MessageId,
                response: result
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                errorCode: error.code
            };
        }
    }
}

class SMTPEmailSender {
    constructor(smtpServer, smtpPort, username, password) {
        this.transporter = nodemailer.createTransporter({
            host: smtpServer,
            port: smtpPort,
            secure: false, // true for 465, false for other ports
            auth: {
                user: username,
                pass: password
            }
        });
    }

    async sendEmail(fromEmail, toEmails, subject, bodyText, bodyHtml = null, attachments = null) {
        const mailOptions = {
            from: fromEmail,
            to: toEmails.join(', '),
            subject: subject,
            text: bodyText
        };

        if (bodyHtml) {
            mailOptions.html = bodyHtml;
        }

        if (attachments) {
            mailOptions.attachments = attachments.map(filePath => ({
                filename: filePath.split('/').pop(),
                path: filePath
            }));
        }

        try {
            const result = await this.transporter.sendMail(mailOptions);
            return {
                success: true,
                messageId: result.messageId,
                response: result
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }
}

// Example usage
async function main() {
    // Configuration from Terraform outputs
    const AWS_REGION = 'us-east-1';
    const CONFIGURATION_SET = 'my-configuration-set';
    const FROM_EMAIL = 'noreply@yourdomain.com';
    
    // SMTP Configuration (from Terraform outputs)
    const SMTP_SERVER = 'email-smtp.us-east-1.amazonaws.com';
    const SMTP_PORT = 587;
    const SMTP_USERNAME = 'your-smtp-access-key-id';
    const SMTP_PASSWORD = 'your-smtp-secret-key';
    
    // Example 1: Using SES API
    const sesSender = new SESEmailSender(CONFIGURATION_SET);
    
    const sesResult = await sesSender.sendSimpleEmail(
        FROM_EMAIL,
        ['recipient@example.com'],
        'Test Email from SES',
        'This is a test email sent using AWS SES API.',
        '<html><body><h1>Test Email</h1><p>This is a test email sent using AWS SES API.</p></body></html>'
    );
    
    if (sesResult.success) {
        console.log(`Email sent successfully! Message ID: ${sesResult.messageId}`);
    } else {
        console.log(`Failed to send email: ${sesResult.error}`);
    }
    
    // Example 2: Using SMTP
    const smtpSender = new SMTPEmailSender(SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD);
    
    const smtpResult = await smtpSender.sendEmail(
        FROM_EMAIL,
        ['recipient@example.com'],
        'Test Email from SMTP',
        'This is a test email sent using SMTP.',
        '<html><body><h1>Test Email</h1><p>This is a test email sent using SMTP.</p></body></html>'
    );
    
    if (smtpResult.success) {
        console.log('SMTP email sent successfully!');
    } else {
        console.log(`Failed to send SMTP email: ${smtpResult.error}`);
    }
}

main().catch(console.error);
```

## Environment Variables

Create a `.env` file for your application:

```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key

# SES Configuration
SES_CONFIGURATION_SET=my-configuration-set
SES_FROM_EMAIL=noreply@yourdomain.com

# SMTP Configuration
SMTP_SERVER=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USERNAME=your-smtp-access-key-id
SMTP_PASSWORD=your-smtp-secret-key
```

## Requirements

### Python
```txt
boto3>=1.26.0
```

### Node.js
```json
{
  "dependencies": {
    "aws-sdk": "^2.1400.0",
    "nodemailer": "^6.9.0"
  }
}
```

## Best Practices

1. **Error Handling**: Always handle errors gracefully
2. **Rate Limiting**: Implement rate limiting to avoid SES limits
3. **Retry Logic**: Implement exponential backoff for retries
4. **Email Validation**: Validate email addresses before sending
5. **Monitoring**: Monitor bounce and complaint rates
6. **Security**: Store credentials securely (use AWS Secrets Manager)
