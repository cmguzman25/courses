

variable "project" {
  description = "Short project name"
  type        = string
  default     = "sales"
}

variable "environment" {
  description = "dev, qa or prod"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa or prod"
  }

}

variable "zones" {
  description = "Data lake zones"
  type        = map(object({ retention_days = number }))
  default = {
    raw       = { retention_days = 30 }
    processed = { retention_days = 90 }
    curated   = { retention_days = 365 }
  }
}

