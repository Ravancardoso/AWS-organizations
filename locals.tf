locals {
  environment_tags = {
    Environment = "Security"
  }

  default_tags = {
    Project     = "AWS-organizations"
    Owner       = "Ravan Cardoso"
    ManagedBy   = "Terraform"
    Departament = "Security"
  }
}
