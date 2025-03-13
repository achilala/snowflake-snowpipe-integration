#!/usr/bin/env python3
"""
This script reads data from the PredictIt API and writes it to an S3 bucket in JSON Lines format.
"""
__author__ = "achilala"
__version__ = "0.0.2"

import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from dotenv import load_dotenv
import json
import logging
import requests
import os
from datetime import datetime

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

def fetch_predictit_data(api_url):
    """
    Fetch data from the PredictIt API.

    Parameters:
    api_url (str): The URL endpoint of the PredictIt API.

    Returns:
    list: List of JSON objects retrieved from the API.
    """
    try:
        response = requests.get(api_url)
        response.raise_for_status()  # Raise an error for bad status codes
        data = response.json()
        # Assuming 'markets' is the key containing the list of market data
        return data.get('markets', [])
    except requests.exceptions.RequestException as e:
        log.error(f"Error fetching data: {e}")
        return []

def upload_to_s3(json_lines, bucket_name, object_key, aws_region='ap-southeast-2'):
    """
    Upload JSON Lines data to an S3 bucket.

    Parameters:
    json_lines (str): The JSON Lines formatted string to upload.
    bucket_name (str): The name of the S3 bucket.
    object_key (str): The S3 object key (file name).
    aws_region (str): AWS region where the bucket is located.

    Returns:
    bool: True if upload was successful, False otherwise.
    """
    try:
        # Initialize a session using Amazon S3
        s3_client = boto3.client('s3', region_name=aws_region)
        
        # Upload the JSON Lines string to the specified S3 bucket
        s3_client.put_object(Bucket=bucket_name, Key=object_key, Body=json_lines)
        
        log.info(f"Successfully uploaded {object_key} to {bucket_name}")
        return True
    except NoCredentialsError:
        log.error("Credentials not available")
        return False
    except ClientError as e:
        log.error(f"Client error: {e}")
        return False

def construct_s3_object_key(namespace, stream_name):
    """
    Construct the S3 object key based on the given parameters and current date/time.

    Parameters:
    namespace (str): The namespace for the S3 path.
    stream_name (str): The stream name for the S3 path.

    Returns:
    str: The constructed S3 object key.
    """
    now = datetime.utcnow()
    year = now.strftime('%Y')
    month = now.strftime('%m')
    day = now.strftime('%d')
    epoch = str(int(now.timestamp()))
    return f"{namespace}/{stream_name}/v1/{year}/{month}/{day}/{epoch}.jsonl"

if __name__ == "__main__":
    # Define the PredictIt API URL
    predictit_api_url = "https://www.predictit.org/api/marketdata/all/"
    
    # Fetch data from the PredictIt API
    data = fetch_predictit_data(predictit_api_url)
    
    if data:
        # Convert the list of JSON objects to JSON Lines format
        json_lines = '\n'.join(json.dumps(record) for record in data)
        
        # Retrieve S3 bucket details from environment variables
        s3_bucket_name = os.getenv("S3_BUCKET_NAME")
        namespace = os.getenv("S3_NAMESPACE")
        stream_name = os.getenv("S3_STREAM_NAME")
        
        # Construct the S3 object key
        s3_object_key = construct_s3_object_key(namespace, stream_name)
        
        # Upload the data to S3
        upload_success = upload_to_s3(json_lines, s3_bucket_name, s3_object_key)
        
        if upload_success:
            log.info("Data successfully uploaded to S3.")
        else:
            log.error("Failed to upload data to S3.")
    else:
        log.error("No data fetched from PredictIt API.")