import os
import boto3
from botocore.exceptions import NoCredentialsError

# Configuration - should be pulled from .env for real usage
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), 'uploads')

def migrate_local_to_s3():
    if not S3_BUCKET_NAME or not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        print("Error: AWS credentials or bucket name not set in environment variables.")
        return

    s3_client = boto3.client(
        's3',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

    print(f"Starting migration of files from {UPLOAD_DIR} to s3://{S3_BUCKET_NAME}/uploads/")

    for root, dirs, files in os.walk(UPLOAD_DIR):
        for file in files:
            local_path = os.path.join(root, file)
            # Create the relative path for S3 key
            relative_path = os.path.relpath(local_path, UPLOAD_DIR)
            s3_key = f"uploads/{relative_path.replace(os.sep, '/')}"

            try:
                print(f"Uploading {local_path} to {s3_key}...")
                s3_client.upload_file(local_path, S3_BUCKET_NAME, s3_key, ExtraArgs={'ACL': 'public-read'})
                print(f"Successfully uploaded {file}")
            except FileNotFoundError:
                print(f"The file {local_path} was not found")
            except NoCredentialsError:
                print("Credentials not available")
            except Exception as e:
                print(f"An error occurred: {e}")

if __name__ == "__main__":
    migrate_local_to_s3()
