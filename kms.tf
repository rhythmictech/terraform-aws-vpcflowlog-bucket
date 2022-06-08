data "aws_iam_policy_document" "key" {

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "this" {
  deletion_window_in_days = 7
  description             = "VPC Flow Log Encryption Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.key.json
  tags = merge(
    {
      "Name" = "vpcflowlog-key"
    },
    var.tags
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/vpcflowlog_key"
  target_key_id = aws_kms_key.this.id
}
