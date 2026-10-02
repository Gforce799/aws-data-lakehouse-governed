variable "aws_region" {
  description = "AWS region used for primary resources."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Short workload name used for resource naming."
  type        = string
  default     = "data-lakehouse-governed"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.name))
    error_message = "Use 3-32 lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, test, stage, or prod."
  }
}

variable "tags" {
  description = "Additional tags merged into all supported resources."
  type        = map(string)
  default     = {}
}

variable "data_lake_admin_arns" {
  description = "Principal ARNs that administer Lake Formation."
  type        = list(string)
  default     = []
}

variable "analyst_principal_arn" {
  description = "Optional analyst role ARN granted SELECT/DESCRIBE on the database."
  type        = string
  default     = ""
}

variable "retention_days" {
  description = "Default lifecycle expiration for noncurrent data versions."
  type        = number
  default     = 365
}
