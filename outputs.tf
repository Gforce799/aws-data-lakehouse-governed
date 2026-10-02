output "zone_bucket_names" {
  description = "Data lake zone buckets."
  value       = { for zone, bucket in aws_s3_bucket.zone : zone => bucket.id }
}

output "glue_database_name" {
  description = "Glue database name."
  value       = aws_glue_catalog_database.lake.name
}

output "athena_workgroup_name" {
  description = "Athena workgroup name."
  value       = aws_athena_workgroup.analytics.name
}
