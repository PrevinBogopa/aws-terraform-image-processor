import json
import boto3
import os
from PIL import Image
import io

s3 = boto3.client("s3")

UPLOAD_BUCKET = os.environ["UPLOAD_BUCKET"]
COMPRESSED_BUCKET = os.environ["COMPRESSED_BUCKET"]

def lambda_handler(event, context):
    if "requestContext" in event:
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Function URL alive"
            })
        }

    for record in event["Records"]:
        key = record["s3"]["object"]["key"]

        obj = s3.get_object(Bucket=UPLOAD_BUCKET, Key=key)
        image = Image.open(io.BytesIO(obj["Body"].read()))

        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", optimize=True, quality=50)

        s3.put_object(
            Bucket=COMPRESSED_BUCKET,
            Key=key,
            Body=buffer.getvalue(),
            ContentType="image/jpeg"
        )

    return {"statusCode": 200}