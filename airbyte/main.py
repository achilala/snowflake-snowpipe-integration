#!/usr/bin/env python3
"""
This script reads data from the Gitlab API and writes it to an s3 bucket
"""
__author__ = "achilala"
__version__ = "0.0.1"

import airbyte as ab
from dotenv import load_dotenv
import logging
from termcolor import colored

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

source: ab.Source = ab.get_source(
    name="source-gitlab",
    config={
        "credentials": {
            "auth_type": "access_token",
            "access_token": ab.get_secret("GITLAB_API_TOKEN")
        },
        "projects": ab.get_secret("GITLAB_PROJECTS"),
        "start_date": ab.get_secret("GITLAB_START_DATE")
    }
)

source.check()
source.select_all_streams()

# list available streams/datasets for this source
for stream in source.get_selected_streams():
    print(colored(stream, "green"))

source.select_streams(
    [
        "users"
    ]
)

read_result: ab.ReadResult = source.read()

destination: ab.Destination = ab.get_destination(
    name="destination-s3",
    config={
        "access_key_id": ab.get_secret("AWS_ACCESS_KEY_ID"),
        "secret_access_key": ab.get_secret("AWS_SECRET_ACCESS_KEY"),
        "s3_bucket_name": ab.get_secret("S3_BUCKET_NAME"),
        "s3_bucket_path": ab.get_secret("S3_BUCKET_PATH"),
        "s3_bucket_region": ab.get_secret("S3_BUCKET_REGION"),
        "s3_path_format": "${NAMESPACE}/${STREAM_NAME}/v1/${YEAR}/${MONTH}/${DAY}/${EPOCH}_",
        "format": {
            "format_type": "JSONL",
            "flattening": "Root level flattening"
        }
    }
)

destination.check()
destination.write(read_result)