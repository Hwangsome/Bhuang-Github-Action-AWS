output "database_name" {
  description = "Glue database name"
  value       = module.glue.database_name
}

output "database_id" {
  description = "Glue database ID"
  value       = module.glue.database_id
}

output "database_arn" {
  description = "Glue database ARN"
  value       = module.glue.database_arn
}

output "crawler_name" {
  description = "Glue crawler name"
  value       = module.glue.crawler_name
}

output "crawler_arn" {
  description = "Glue crawler ARN"
  value       = module.glue.crawler_arn
}

output "table_name" {
  description = "Glue table name"
  value       = module.glue.table_name
}

output "table_id" {
  description = "Glue table ID"
  value       = module.glue.table_id
}
