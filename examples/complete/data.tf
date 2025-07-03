data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

### Access Logs Bucket Policy
data "aws_iam_policy_document" "access_logs_bucket" {
  policy_id = "s3_bucket_lb_logs"
  statement {
    sid     = "denyOutdatedTLS"
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "arn:aws:s3:::${local.bucket}",
      "arn:aws:s3:::${local.bucket}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
  statement {
    sid     = "denyInsecureTransport"
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "arn:aws:s3:::${local.bucket}",
      "arn:aws:s3:::${local.bucket}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid       = "ELBRegionAllow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.elb_service_account_id}:root"]
    }
  }
  statement {
    sid = "LogDeliveryAllowWrite"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl"
    ]
    resources = ["arn:aws:s3:::${local.bucket}"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.${local.dns_suffix}"]
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
  statement {
    sid       = "ReadLogsroot"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "LogDeliveryAllowWriteS3"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket}/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.${local.dns_suffix}"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    sid       = "LogDeliveryAllow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket}/*"]
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.${local.dns_suffix}"]
    }
  }
}

data "aws_elb_service_account" "main" {}

data "aws_vpc" "supporting" {
  filter {
    name   = "tag:Name"
    values = [var.supporting_resources_name]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pub.*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.supporting_resources_name}*.pri.*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.supporting_resources_name
}

data "aws_kms_alias" "supporting_kms" {
  name = "alias/${var.supporting_resources_name}"
}

data "aws_iam_policy_document" "task_role_policy_doc" {
  #checkov:skip=CKV_AWS_356:"Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:logs:*:*:*"]
  }
}
