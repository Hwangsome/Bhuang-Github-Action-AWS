module "glue" {
  source  = "cloudposse/glue/aws"
  version = "0.4.0"

  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  delimiter                  = var.delimiter
  attributes                 = var.attributes
  tags                       = var.tags

  # Glue Catalog Database settings
  database_name              = var.database_name
  database_description       = var.database_description
  database_parameters        = var.database_parameters
  catalog_id                 = var.catalog_id
  create_table               = var.create_table
  create_crawler             = var.create_crawler
  
  # Glue Table settings (optional, used if create_table = true)
  table_name                 = var.table_name
  table_description          = var.table_description
  table_parameters           = var.table_parameters
  table_storage_descriptor   = var.table_storage_descriptor
  table_partition_keys       = var.table_partition_keys
  table_retention            = var.table_retention
  
  # Glue Crawler settings (optional, used if create_crawler = true)
  crawler_name               = var.crawler_name
  crawler_description        = var.crawler_description
  crawler_schedule           = var.crawler_schedule
  crawler_security_configuration = var.crawler_security_configuration
  crawler_classifiers        = var.crawler_classifiers
  crawler_s3_targets         = var.crawler_s3_targets
  crawler_jdbc_targets       = var.crawler_jdbc_targets
  crawler_dynamodb_targets   = var.crawler_dynamodb_targets
  crawler_mongodb_targets    = var.crawler_mongodb_targets
  crawler_configuration      = var.crawler_configuration
  crawler_table_prefix       = var.crawler_table_prefix
  crawler_schema_change_policy = var.crawler_schema_change_policy
  crawler_recrawl_policy     = var.crawler_recrawl_policy
  crawler_lineage_configuration = var.crawler_lineage_configuration
  crawler_role_arn           = var.crawler_role_arn
}
