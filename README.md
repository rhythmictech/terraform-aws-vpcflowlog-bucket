# terraform-aws-vpcflowlog-bucket

[![](https://github.com/rhythmictech/terraform-aws-vpcflowlog-bucket/workflows/check/badge.svg)](https://github.com/rhythmictech/terraform-aws-vpcflowlog-bucket/actions)

Creates an S3 bucket suitable for receiving VPC flow logs from one or more AWS account. Uses a KMS CMK, which is necessary for CIS compliance. Requires an external bucket to route S3 access logs to (also for CIS compliance).

Example:


```
module "vpcflowlog-bucket" {
  source              = "git::https://github.com/rhythmictech/terraform-aws-vpcflowlogs.git"
  allowed_account_ids = ["123456789012", "123456789013"]
  logging_bucket      = "example-s3-access-logs-bucket"
  region              = "us-east-1"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_account\_ids | Optional list of AWS Account IDs that are permitted to write to the bucket | list(string) | `[]` | no |
| logging\_bucket | S3 bucket to send request logs to the VPC flow log bucket to | string | n/a | yes |
| region | Region VPC flow logs will be sent to | string | n/a | yes |
| tags | Tags to include on resources that support it | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_id | KMS key |
| s3\_bucket\_arn | The ARN of the bucket |
| s3\_bucket\_name | The name of the bucket |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Related Projects
* [VPC Flow Logs](https://github.com/rhythmictech/terraform-aws-vpc-flowlogs)
