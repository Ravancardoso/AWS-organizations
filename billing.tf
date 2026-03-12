# Management Account Monthly Budget
# Hard limit of $100/mo. Alerts at 70% and 100% of actual spend.
resource "aws_budgets_budget" "conta_master" {
  name         = "Budget-Conta-Master"
  budget_type  = "COST"
  limit_amount = "100.00"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 70
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.billing_contacts
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.billing_contacts
  }
}

# Sandbox OU Monthly Budget
# Dynamic limit based on var.sandbox_budget_limit. Alerts at 80% and 100% of actual spend.
resource "aws_budgets_budget" "sandbox" {
  name         = "Budget-Sandbox-OU"
  budget_type  = "COST"
  limit_amount = tostring(var.sandbox_budget_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.billing_contacts
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.billing_contacts
  }
}

# AWS Budgets Execution Role
# Allows the budgets service to perform automated actions when thresholds are met.
resource "aws_iam_role" "budgets_execution_role" {
  name = "AWSBudgetsExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "budgets.amazonaws.com" }
    }]
  })
}
