# Test Spark Job for EMR Serverless

This directory contains a test PySpark job that can be used with AWS EMR Serverless. The job demonstrates common Spark operations including data reading, transformation, aggregation, and writing results to S3.

## Job Features

- Reads data from S3 (with fallback to generated sample data)
- Performs data transformations and aggregations
- Writes results to S3 in multiple formats (Parquet, CSV, JSON)
- Includes comprehensive logging
- Configurable via command-line arguments

## Prerequisites

- An AWS account with access to EMR Serverless
- An S3 bucket for input data, output data, and logs
- Appropriate IAM roles and permissions

## Usage with EMR Serverless

### 1. Upload the Script to S3

First, upload the Spark script to your S3 bucket:

```bash
aws s3 cp test_spark_job.py s3://your-bucket/scripts/test_spark_job.py
```

### 2. Run the GitHub Actions Workflow

Use the `emr-serverless-spark.yml` GitHub Actions workflow to run the job:

1. Go to the Actions tab in your GitHub repository
2. Select "EMR Serverless Spark Workflow"
3. Click "Run workflow"
4. Fill in the parameters:
   - **Application Name**: Name for your EMR Serverless application
   - **Spark Script**: `s3://your-bucket/scripts/test_spark_job.py`
   - **Job Name**: A name for your Spark job
   - **Spark Submit Parameters**: `--conf spark.executor.cores=4 --conf spark.executor.memory=8g`
   - **S3 Logs Bucket**: `s3://your-bucket/logs/`
   - **Action**: Choose "both" to create the application and run the job

### 3. Additional Job Parameters

The test Spark job accepts the following parameters:

- `--input-path`: S3 path to input data (defaults to a public sample dataset)
- `--output-path`: S3 path for output data (required)
- `--log-level`: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)

Example Spark submit parameters with job arguments:

```
--conf spark.executor.cores=4 --conf spark.executor.memory=8g -- --input-path s3://your-bucket/input/data.csv --output-path s3://your-bucket/output/
```

## Example Output

The job will create three subdirectories in your specified output location:

- `parquet/`: Data in Parquet format
- `csv/`: Data in CSV format
- `json/`: Data in JSON format

## Monitoring and Troubleshooting

- Check the GitHub Actions workflow logs for execution details
- EMR Serverless logs are available in the S3 logs bucket you specified
- For more detailed monitoring, use the AWS Console or CLI to view the EMR Serverless application and job run details
