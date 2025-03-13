#!/bin/bash
# Script to upload the test Spark job to S3

# Default values
DEFAULT_BUCKET=""
DEFAULT_PREFIX="scripts"
SCRIPT_NAME="test_spark_job.py"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --bucket)
      BUCKET="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;

    --help)
      echo "Usage: $0 --bucket <s3-bucket-name> [--prefix <s3-prefix>]"
      echo ""
      echo "Options:"
      echo "  --bucket <name>    S3 bucket name (required)"
      echo "  --prefix <prefix>  S3 prefix/folder (default: scripts)"

      echo "  --help             Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Check if bucket is provided
if [ -z "$BUCKET" ]; then
  echo "Error: S3 bucket name is required"
  echo "Usage: $0 --bucket <s3-bucket-name> [--prefix <s3-prefix>]"
  exit 1
fi

# Set default prefix if not provided
if [ -z "$PREFIX" ]; then
  PREFIX="$DEFAULT_PREFIX"
fi

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Check if the script file exists
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Error: Spark job script not found at $SCRIPT_PATH"
  exit 1
fi

# Check if bucket exists
echo "Checking if bucket s3://$BUCKET exists..."
if aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; then
  echo "Bucket s3://$BUCKET exists."
else
  echo "Bucket s3://$BUCKET does not exist."
  echo "Creating bucket s3://$BUCKET..."
  
  if aws s3 mb "s3://$BUCKET"; then
    echo "Bucket created successfully."
  else
    echo "Failed to create bucket. Please check your AWS credentials and permissions."
    exit 1
  fi
fi

# Upload to S3
echo "Uploading Spark job to s3://$BUCKET/$PREFIX/$SCRIPT_NAME..."
aws s3 cp "$SCRIPT_PATH" "s3://$BUCKET/$PREFIX/$SCRIPT_NAME"

# Check if upload was successful
if [ $? -eq 0 ]; then
  echo "Upload successful!"
  echo ""
  echo "To use this script with EMR Serverless, set the Spark script path to:"
  echo "s3://$BUCKET/$PREFIX/$SCRIPT_NAME"
  echo ""
  echo "Example output path for the job:"
  echo "s3://$BUCKET/output/$(date +%Y%m%d)/"
else
  echo "Upload failed."
fi
