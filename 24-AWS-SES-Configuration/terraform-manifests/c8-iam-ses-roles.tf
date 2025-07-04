# SES IAM Role for sending emails
resource "aws_iam_role" "ses_sending_role" {
  name = "${local.name}-ses-sending-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.ses_tags
}

# SES IAM Policy for sending emails
resource "aws_iam_policy" "ses_sending_policy" {
  name        = "${local.name}-ses-sending-policy"
  description = "Policy for sending emails through SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [
          aws_ses_domain_identity.domain.arn,
          "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identity/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [
          "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:configuration-set/${aws_ses_configuration_set.configuration_set.name}"
        ]
      }
    ]
  })

  tags = local.ses_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ses_sending_policy_attachment" {
  role       = aws_iam_role.ses_sending_role.name
  policy_arn = aws_iam_policy.ses_sending_policy.arn
}

# IAM Instance Profile for EC2 instances
resource "aws_iam_instance_profile" "ses_instance_profile" {
  name = "${local.name}-ses-instance-profile"
  role = aws_iam_role.ses_sending_role.name
  tags = local.ses_tags
}

# SES SMTP User (for SMTP authentication)
resource "aws_iam_user" "ses_smtp_user" {
  name = "${local.name}-ses-smtp-user"
  tags = local.ses_tags
}

# SES SMTP User Policy
resource "aws_iam_user_policy" "ses_smtp_user_policy" {
  name = "${local.name}-ses-smtp-user-policy"
  user = aws_iam_user.ses_smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# SES SMTP User Access Key
resource "aws_iam_access_key" "ses_smtp_user_key" {
  user = aws_iam_user.ses_smtp_user.name
}
