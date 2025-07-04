# SES Configuration Set
resource "aws_ses_configuration_set" "configuration_set" {
  name = var.configuration_set_name
}

# SES Configuration Set Event Destination for Bounces
resource "aws_sesv2_configuration_set_event_destination" "bounce" {
  count                    = var.enable_sns_notifications ? 1 : 0
  event_destination_name   = "${var.configuration_set_name}-bounce"
  configuration_set_name   = aws_ses_configuration_set.configuration_set.name
  
  event_destination {
    enabled          = true
    matching_event_types = ["bounce"]
    
    sns_destination {
      topic_arn = aws_sns_topic.bounce_topic[0].arn
    }
  }
}

# SES Configuration Set Event Destination for Complaints
resource "aws_sesv2_configuration_set_event_destination" "complaint" {
  count                    = var.enable_sns_notifications ? 1 : 0
  event_destination_name   = "${var.configuration_set_name}-complaint"
  configuration_set_name   = aws_ses_configuration_set.configuration_set.name
  
  event_destination {
    enabled          = true
    matching_event_types = ["complaint"]
    
    sns_destination {
      topic_arn = aws_sns_topic.complaint_topic[0].arn
    }
  }
}

# SES Configuration Set Event Destination for Delivery
resource "aws_sesv2_configuration_set_event_destination" "delivery" {
  count                    = var.enable_sns_notifications ? 1 : 0
  event_destination_name   = "${var.configuration_set_name}-delivery"
  configuration_set_name   = aws_ses_configuration_set.configuration_set.name
  
  event_destination {
    enabled          = true
    matching_event_types = ["delivery"]
    
    sns_destination {
      topic_arn = aws_sns_topic.delivery_topic[0].arn
    }
  }
}
