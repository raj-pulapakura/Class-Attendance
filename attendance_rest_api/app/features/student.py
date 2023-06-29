from pydantic import BaseModel
from typing import Optional
import boto3
import os

class StudentItem(BaseModel):
    student_id: Optional[str]
    first_name: str
    last_name: str
    primary_contact: str
    secondary_contact: str

def get_student_table():
    dynamodb = boto3.resource(
        'dynamodb',
        # aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
        # aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"],
        # aws_access_key_id="AKIAXD26HXT4NTXFP56V",
        # aws_secret_access_key="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",
    )
    table = dynamodb.Table("Student")
    return table