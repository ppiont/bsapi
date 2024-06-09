variable "function_app_name" {
  type    = string
  default = "helloworld"
}

variable "resource_group_name" {
  type    = string
  default = "bestseller"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "environment" {
  type    = string
  default = "prod"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Allowed values for environment are \"dev\", \"test\", or \"prod\"."
  }
}

variable "package_source_dir" {
  type    = string
  default = "../../code/function_app"
}

variable "package_output_path" {
  type    = string
  default = "../../dist/functionapp.zip"
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  description = "Tags to apply to all taggable resources in this module"
  type        = map(string)
  default     = {}
}
