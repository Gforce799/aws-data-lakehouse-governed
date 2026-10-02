data "aws_caller_identity" "current" {}

locals {
  zones = {
    raw       = "${local.name_prefix}-raw-${data.aws_caller_identity.current.account_id}"
    curated   = "${local.name_prefix}-curated-${data.aws_caller_identity.current.account_id}"
    analytics = "${local.name_prefix}-analytics-${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_kms_key" "lake" {
  description         = "KMS key for ${local.name_prefix} data lake"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_s3_bucket" "zone" {
  for_each = local.zones
  bucket   = each.value
  tags     = merge(local.tags, { Zone = each.key })
}

resource "aws_s3_bucket_public_access_block" "zone" {
  for_each                = aws_s3_bucket.zone
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "zone" {
  for_each = aws_s3_bucket.zone
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "zone" {
  for_each = aws_s3_bucket.zone
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.lake.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "zone" {
  for_each = aws_s3_bucket.zone
  bucket   = each.value.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
  }
}

resource "aws_glue_catalog_database" "lake" {
  name        = replace(local.name_prefix, "-", "_")
  description = "Governed data lake database for ${local.name_prefix}"
}

resource "aws_athena_workgroup" "analytics" {
  name  = "${local.name_prefix}-analytics"
  state = "ENABLED"
  tags  = local.tags

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.zone["analytics"].id}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.lake.arn
      }
    }
  }
}

resource "aws_lakeformation_data_lake_settings" "this" {
  count = length(var.data_lake_admin_arns) > 0 ? 1 : 0

  dynamic "admins" {
    for_each = toset(var.data_lake_admin_arns)
    content {
      data_lake_principal_identifier = admins.value
    }
  }
}

resource "aws_lakeformation_resource" "zone" {
  for_each = aws_s3_bucket.zone
  arn      = each.value.arn
}

resource "aws_lakeformation_permissions" "analyst_database" {
  count       = var.analyst_principal_arn != "" ? 1 : 0
  principal   = var.analyst_principal_arn
  permissions = ["DESCRIBE"]

  database {
    name = aws_glue_catalog_database.lake.name
  }
}
