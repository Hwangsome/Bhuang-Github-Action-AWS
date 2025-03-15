variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  default     = "example"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
  default     = "dev"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "glue-service"
}

variable "delimiter" {
  type        = string
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
  default     = "-"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (e.g. `1`)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
  default     = {}
}

variable "database_name" {
  type        = string
  description = "The name of the database"
  default     = null
}

variable "database_description" {
  type        = string
  description = "Description of the database"
  default     = "AWS Glue catalog database"
}

variable "database_parameters" {
  type        = map(string)
  description = "A list of key-value pairs that define parameters and properties of the database"
  default     = {}
}

variable "catalog_id" {
  type        = string
  description = "ID of the Glue Catalog to create the database in. If omitted, this defaults to the AWS Account ID"
  default     = null
}

variable "create_table" {
  type        = bool
  description = "Whether to create a table"
  default     = false
}

variable "create_crawler" {
  type        = bool
  description = "Whether to create a crawler"
  default     = false
}

# Glue Table variables (optional, used if create_table = true)
variable "table_name" {
  type        = string
  description = "The name of the table"
  default     = null
}

variable "table_description" {
  type        = string
  description = "Description of the table"
  default     = "AWS Glue catalog table"
}

variable "table_parameters" {
  type        = map(string)
  description = "Properties associated with this table"
  default     = {}
}

variable "table_storage_descriptor" {
  type        = any
  description = "A storage descriptor object containing information about the physical storage of this table"
  default     = {}
}

variable "table_partition_keys" {
  type        = list(map(string))
  description = "A list of columns by which the table is partitioned. Only primitive types are supported as partition keys"
  default     = []
}

variable "table_retention" {
  type        = number
  description = "Retention time for this table"
  default     = null
}

# Glue Crawler variables (optional, used if create_crawler = true)
variable "crawler_name" {
  type        = string
  description = "Name of the crawler"
  default     = null
}

variable "crawler_description" {
  type        = string
  description = "Description of the crawler"
  default     = "AWS Glue crawler"
}

variable "crawler_schedule" {
  type        = string
  description = "The schedule of the crawler"
  default     = null
}

variable "crawler_security_configuration" {
  type        = string
  description = "The name of the Security Configuration to be used by the crawler"
  default     = null
}

variable "crawler_classifiers" {
  type        = list(string)
  description = "List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification"
  default     = null
}

variable "crawler_s3_targets" {
  type        = list(map(string))
  description = "List of nested Amazon S3 target arguments"
  default     = []
}

variable "crawler_jdbc_targets" {
  type        = list(map(string))
  description = "List of nested JDBC target arguments"
  default     = []
}

variable "crawler_dynamodb_targets" {
  type        = list(map(string))
  description = "List of nested DynamoDB target arguments"
  default     = []
}

variable "crawler_mongodb_targets" {
  type        = list(map(string))
  description = "List of nested MongoDB target arguments"
  default     = []
}

variable "crawler_configuration" {
  type        = string
  description = "JSON string of crawler configuration"
  default     = null
}

variable "crawler_table_prefix" {
  type        = string
  description = "The table prefix used for catalog tables that are created"
  default     = null
}

variable "crawler_schema_change_policy" {
  type        = map(string)
  description = "Policy for the crawler's update and deletion behavior"
  default     = {}
}

variable "crawler_recrawl_policy" {
  type        = map(string)
  description = "A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run"
  default     = {}
}

variable "crawler_lineage_configuration" {
  type        = map(string)
  description = "Specifies data lineage configuration settings for the crawler"
  default     = {}
}

variable "crawler_role_arn" {
  type        = string
  description = "The IAM role friendly name (including path without leading slash) or ARN of an IAM role with the required permissions"
  default     = null
}
