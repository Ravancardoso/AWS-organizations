# Organization-wide CloudTrail trailing to central S3 bucket
resource "aws_cloudtrail" "organization_trail" {
  name                          = "${var.organization_name}-Organization-Trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true

  # Allow CloudTrail to use CloudWatch logs for real-time alerts
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_logs.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
}

# CloudWatch Log Group for CloudTrail alerts
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/${var.organization_name}-Organization-Trail"
  retention_in_days = 90
}

# IAM role to allow CloudTrail to write to CloudWatch
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    sid     = "CloudTrailAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_logs" {
  name               = "CloudTrail-CloudWatch-Access-Role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

# IAM policy for CloudTrail CloudWatch writes
data "aws_iam_policy_document" "cloudtrail_put_logs" {
  statement {
    sid    = "CloudTrailAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.cloudtrail_logs.arn]
  }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name   = "CloudTrail-PutLogs-Policy"
  role   = aws_iam_role.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_put_logs.json
}