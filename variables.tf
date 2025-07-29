# This file defines the input variables for the Terraform module.

variable "domain" {
  type        = string
  description = "Public domain for the external LB cert"
  default     = "example.com"
}