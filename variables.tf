variable "allowed_account_ids" {
  default     = []
  description = "Optional list of AWS Account IDs that are permitted to write to the bucket"
  type        = list(string)
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
