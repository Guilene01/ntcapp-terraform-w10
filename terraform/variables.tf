variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on resources"
  type        = bool
  default     = false  # Set to false for CI/CD
}