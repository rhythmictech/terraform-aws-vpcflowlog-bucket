variable "allowed_account_ids" {
  default     = []
  description = "Optional list of AWS Account IDs that are permitted to write to the bucket"
  type        = list(string)
}

variable "lifecycle_rules" {
  description = "lifecycle rules to apply to the bucket"

  default = [
    {
      id                            = "expire-noncurrent-objects-after-ninety-days"
      noncurrent_version_expiration = 90
    },
    {
      id = "transition-to-IA-after-30-days"
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
    },
    {
      id         = "delete-after-seven-years"
      expiration = 2557
    },
  ]

  type = list(object(
    {
      id                            = string
      enabled                       = optional(bool, true)
      expiration                    = optional(number)
      prefix                        = optional(string)
      noncurrent_version_expiration = optional(number)
      transition = optional(list(object({
        days          = number
        storage_class = string
      })))
  }))
}

variable "lifecycle_transition_default_minimum_object_size" {
  default     = "varies_by_storage_class"
  description = "The default minimum object size behavior applied to the lifecycle configuration"
  type        = string
}

variable "logging_bucket" {
  description = "S3 bucket to send request logs to the VPC flow log bucket to"
  type        = string
}

variable "region" {
  description = "Region VPC flow logs will be sent to"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to include on resources that support it"
  type        = map(string)
}
