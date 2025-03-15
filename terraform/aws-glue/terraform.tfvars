namespace              = "example"
stage                  = "dev"
name                   = "data-catalog"
delimiter              = "-"
attributes             = ["glue"]
tags                   = {
  Environment = "development"
  Project     = "data-pipeline"
}

# Glue Database设置
database_name          = "example_data_catalog"
database_description   = "AWS Glue Catalog Database for data analysis"

# 启用爬虫创建
create_crawler         = true
crawler_name           = "s3-data-crawler"
crawler_description    = "Crawler for S3 data sources"
crawler_schedule       = "cron(0 0 * * ? *)"  # 每天午夜运行
crawler_table_prefix   = "raw_"

# S3爬虫目标设置
crawler_s3_targets     = [
  {
    path = "s3://example-data-bucket/data/"
    exclusions = ["**.temp", "**.tmp"]
  }
]

# 爬虫Schema变更策略
crawler_schema_change_policy = {
  update_behavior = "UPDATE_IN_DATABASE"
  delete_behavior = "LOG"
}
