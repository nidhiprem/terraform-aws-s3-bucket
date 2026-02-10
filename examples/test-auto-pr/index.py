import json
import boto3
import os

s3 = boto3.client('s3')

def handler(event, context):
    bucket_name = os.environ['BUCKET_NAME']
    
    # Lambda depends on S3 bucket
    response = s3.list_objects_v2(Bucket=bucket_name, MaxKeys=10)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Successfully accessed bucket {bucket_name}',
            'object_count': response.get('KeyCount', 0)
        })
    }
