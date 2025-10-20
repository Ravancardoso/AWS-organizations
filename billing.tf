
# BUDGET

resource "aws_budgets_budget" "Conta-Master" {
  name_prefix         = "Conta-Master"
  budget_type         = "COST"
  limit_amount        = var.Conta-Master_budget_limit = 100,00
  limit_unit          = "USD"
  time_unit           = "MONTHLY"
}
  


# 2. CONFIGURAÇÃO DE NOTIFICAÇÕES 

# Budget 60%

resource "aws_budgets_budget_notification" "Conta-Master_percent_alert" {
  budget_name         = aws_budgets_budget.sandbox_monthly_budget.name
  notification_type   = "ACTUAL" 
  comparison_operator = "GREATER_THAN"
  threshold           = 70
  threshold_type      = "PERCENTAGE"
  
  subscriber_email_addresses = var.billing_contacts 
}

# Budget 100%

resource "aws_budgets_budget_notification" "sandbox_100_percent_alert" {
  budget_name         = aws_budgets_budget.sandbox_monthly_budget.name
  notification_type   = "ACTUAL"
  comparison_operator = "GREATER_THAN"
  threshold           = 100
  threshold_type      = "PERCENTAGE"
  
  subscriber_email_addresses = var.billing_contacts
}