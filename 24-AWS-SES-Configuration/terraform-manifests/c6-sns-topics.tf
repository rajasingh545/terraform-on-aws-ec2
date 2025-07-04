# SNS Topic for Bounce Notifications
resource "aws_sns_topic" "bounce_topic" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = var.sns_bounce_topic_name
  tags  = local.ses_tags
}

# SNS Topic for Complaint Notifications
resource "aws_sns_topic" "complaint_topic" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = var.sns_complaint_topic_name
  tags  = local.ses_tags
}

# SNS Topic for Delivery Notifications
resource "aws_sns_topic" "delivery_topic" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = "${local.name}-ses-delivery-notifications"
  tags  = local.ses_tags
}

# SNS Topic Policy for Bounce Topic
resource "aws_sns_topic_policy" "bounce_policy" {
  count = var.enable_sns_notifications ? 1 : 0
  arn   = aws_sns_topic.bounce_topic[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.bounce_topic[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# SNS Topic Policy for Complaint Topic
resource "aws_sns_topic_policy" "complaint_policy" {
  count = var.enable_sns_notifications ? 1 : 0
  arn   = aws_sns_topic.complaint_topic[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.complaint_topic[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# SNS Topic Policy for Delivery Topic
resource "aws_sns_topic_policy" "delivery_policy" {
  count = var.enable_sns_notifications ? 1 : 0
  arn   = aws_sns_topic.delivery_topic[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.delivery_topic[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# SNS Subscription for Bounce Notifications (Email)
resource "aws_sns_topic_subscription" "bounce_email_subscription" {
  count     = var.enable_sns_notifications ? 1 : 0
  topic_arn = aws_sns_topic.bounce_topic[0].arn
  protocol  = "email"
  endpoint  = var.from_email
}

# SNS Subscription for Complaint Notifications (Email)
resource "aws_sns_topic_subscription" "complaint_email_subscription" {
  count     = var.enable_sns_notifications ? 1 : 0
  topic_arn = aws_sns_topic.complaint_topic[0].arn
  protocol  = "email"
  endpoint  = var.from_email
}
