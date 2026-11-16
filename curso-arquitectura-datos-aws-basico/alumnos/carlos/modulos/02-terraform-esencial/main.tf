locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_s3_bucket" "zone" {

  for_each = var.zones
  bucket   = "${local.prefix}-${each.key}"

  tags = {
    Zone          = each.key,
    RetentionDays = tostring(each.value.retention_days)
  }

}