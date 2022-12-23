data "aws_caller_identity" "current" {
}

data "aws_partition" "current" {
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  # Account IDs that will have access to stream CloudTrail logs
  account_ids = concat([local.account_id], var.allowed_account_ids)

  # Format account IDs into necessary resource lists.
  bucket_policy_put_resources = formatlist("${aws_s3_bucket.this.arn}/AWSLogs/%s/*", local.account_ids)
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.account_id}-${var.region}-vpcflowlog"
  tags   = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.lifecycle_rules == null ? 0 : 1

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    iterator = rule
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = lookup(rule.value, "prefix", null)
      }

      expiration {
        days = lookup(rule.value, "expiration", 2147483647)
      }

      noncurrent_version_expiration {
        noncurrent_days = lookup(rule.value, "noncurrent_version_expiration", 2147483647)
      }

      dynamic "transition" {
        for_each = coalesce(rule.value.transition, [])

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_bucket
  target_prefix = "${local.account_id}-${var.region}-vpcflowlog/"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}


data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = local.bucket_policy_put_resources

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}
