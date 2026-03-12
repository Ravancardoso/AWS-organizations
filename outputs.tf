# OUTPUTS

output "organization_id" {
  description = "Main AWS Organization ID."
  value       = aws_organizations_organization.main.id
}

output "management_account_id" {
  description = "ID da Management Account."
  value       = aws_organizations_account.management.id
}

output "security_ou_id" {
  description = "Security Organizational Unit ID."
  value       = aws_organizations_organizational_unit.security.id
}

output "workloads_ou_id" {
  description = "Workloads Organizational Unit ID."
  value       = aws_organizations_organizational_unit.workloads.id
}

output "management_ou_id" {
  description = "Management Organizational Unit ID."
  value       = aws_organizations_organizational_unit.management.id
}
