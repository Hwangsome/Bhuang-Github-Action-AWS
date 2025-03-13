#!/usr/bin/env python3
"""
Test Spark Job for EMR Serverless
This script demonstrates common Spark operations including:
- Reading data from S3
- Data transformation
- Aggregation
- Writing results back to S3
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, year, month, dayofmonth, hour, minute, sum as spark_sum, avg, count, max as spark_max
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, TimestampType
import argparse
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def create_spark_session():
    """Create and return a Spark session configured for EMR Serverless."""
    spark = SparkSession.builder \
        .appName("EMR Serverless Test Job") \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .config("spark.sql.adaptive.skewJoin.enabled", "true") \
        .getOrCreate()
    
    logger.info("Spark session created")
    return spark

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Test Spark Job for EMR Serverless")
    parser.add_argument("--input-path", type=str, default="s3://aws-emr-resources-589476926738-us-east-1/samples/flights/flight_data.csv",
                        help="S3 path to input data")
    parser.add_argument("--output-path", type=str, required=True,
                        help="S3 path for output data")
    parser.add_argument("--log-level", type=str, default="INFO",
                        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
                        help="Set the logging level")
    return parser.parse_args()

def generate_sample_data(spark):
    """Generate sample data if no input data is provided."""
    logger.info("Generating sample data")
    
    # Define schema for sample data
    schema = StructType([
        StructField("id", IntegerType(), False),
        StructField("category", StringType(), True),
        StructField("value", DoubleType(), True),
        StructField("timestamp", TimestampType(), True)
    ])
    
    # Create sample data
    data = [
        (1, "A", 10.5, "2023-01-01 12:00:00"),
        (2, "B", 20.3, "2023-01-01 12:30:00"),
        (3, "A", 15.7, "2023-01-01 13:00:00"),
        (4, "C", 8.9, "2023-01-01 13:30:00"),
        (5, "B", 25.1, "2023-01-01 14:00:00"),
        (6, "A", 12.3, "2023-01-01 14:30:00"),
        (7, "C", 9.8, "2023-01-01 15:00:00"),
        (8, "B", 22.7, "2023-01-01 15:30:00"),
        (9, "A", 11.2, "2023-01-01 16:00:00"),
        (10, "C", 7.5, "2023-01-01 16:30:00")
    ]
    
    # Create DataFrame
    df = spark.createDataFrame(data, schema)
    logger.info(f"Generated sample data with {df.count()} rows")
    return df

def read_data(spark, input_path):
    """Read data from S3."""
    logger.info(f"Reading data from: {input_path}")
    
    try:
        # Check if the input path exists and is accessible
        if input_path.startswith("s3://"):
            # Try to read the data
            df = spark.read.option("header", "true").csv(input_path)
            logger.info(f"Successfully read {df.count()} rows from {input_path}")
            return df
        else:
            logger.warning(f"Input path {input_path} is not an S3 path. Generating sample data instead.")
            return generate_sample_data(spark)
    except Exception as e:
        logger.warning(f"Failed to read data from {input_path}: {str(e)}")
        logger.info("Falling back to sample data generation")
        return generate_sample_data(spark)

def process_data(df):
    """Process the data with various transformations."""
    logger.info("Processing data")
    
    # Print schema and sample data
    logger.info("Input schema:")
    df.printSchema()
    
    logger.info("Sample data:")
    df.show(5, truncate=False)
    
    # Add timestamp components if timestamp column exists
    if "timestamp" in df.columns:
        logger.info("Adding timestamp components")
        df = df.withColumn("year", year(col("timestamp"))) \
               .withColumn("month", month(col("timestamp"))) \
               .withColumn("day", dayofmonth(col("timestamp"))) \
               .withColumn("hour", hour(col("timestamp"))) \
               .withColumn("minute", minute(col("timestamp")))
    
    # Perform aggregations by category if category column exists
    if "category" in df.columns and "value" in df.columns:
        logger.info("Performing aggregations by category")
        agg_df = df.groupBy("category").agg(
            spark_sum("value").alias("total_value"),
            avg("value").alias("avg_value"),
            count("*").alias("count"),
            spark_max("value").alias("max_value")
        )
        
        logger.info("Aggregation results:")
        agg_df.show()
        
        return agg_df
    else:
        logger.info("Required columns for aggregation not found, returning original DataFrame")
        return df

def write_data(df, output_path):
    """Write processed data to S3."""
    logger.info(f"Writing data to: {output_path}")
    
    # Write data in Parquet format
    parquet_path = os.path.join(output_path, "parquet")
    df.write.mode("overwrite").parquet(parquet_path)
    logger.info(f"Data written to {parquet_path} in Parquet format")
    
    # Write data in CSV format
    csv_path = os.path.join(output_path, "csv")
    df.write.mode("overwrite").option("header", "true").csv(csv_path)
    logger.info(f"Data written to {csv_path} in CSV format")
    
    # Write data in JSON format
    json_path = os.path.join(output_path, "json")
    df.write.mode("overwrite").json(json_path)
    logger.info(f"Data written to {json_path} in JSON format")

def main():
    """Main function to execute the Spark job."""
    # Parse arguments
    args = parse_arguments()
    
    # Set log level
    logging.getLogger().setLevel(getattr(logging, args.log_level))
    
    # Create Spark session
    spark = create_spark_session()
    
    try:
        # Log Spark configuration
        logger.info(f"Spark version: {spark.version}")
        logger.info(f"Spark configuration: {spark.sparkContext.getConf().getAll()}")
        
        # Read data
        df = read_data(spark, args.input_path)
        
        # Process data
        result_df = process_data(df)
        
        # Write results
        write_data(result_df, args.output_path)
        
        logger.info("Job completed successfully")
    except Exception as e:
        logger.error(f"Job failed: {str(e)}", exc_info=True)
        raise
    finally:
        # Stop Spark session
        spark.stop()
        logger.info("Spark session stopped")

if __name__ == "__main__":
    main()
