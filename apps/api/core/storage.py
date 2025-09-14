import boto3
from botocore.client import Config

from .config import settings

def get_s3_client():
    return boto3.client(
        "s3",
        endpoint_url=settings.S3_ENDPOINT,
        aws_access_key_id=settings.S3_ACCESS_KEY,
        aws_secret_access_key=settings.S3_SECRET_KEY,
        config=Config(signature_version="s3v4"),
        region_name=settings.S3_REGION,
    )

def ensure_bucket_exists():
    s3 = get_s3_client()
    try:
        s3.head_bucket(Bucket=settings.S3_BUCKET_UPLOADS)
    except Exception:
        s3.create_bucket(Bucket=settings.S3_BUCKET_UPLOADS)

def generate_presigned_upload_url(file_key: str, content_type: str | None = None, expires_in: int = 3600) -> dict:
    s3 = get_s3_client()
    fields = {}
    conditions = [["content-length-range", 0, 10485760]]
    if content_type:
        fields["Content-Type"] = content_type
        conditions.append({"Content-Type": content_type})
    post = s3.generate_presigned_post(
        Bucket=settings.S3_BUCKET_UPLOADS, Key=file_key, Fields=fields or None, Conditions=conditions, ExpiresIn=expires_in
    )
    return post

def generate_file_key(user_id: str, filename: str, folder: str = "uploads") -> str:
    import hashlib
    from datetime import datetime

    ext = filename.rsplit(".", 1)[-1] if "." in filename else ""
    file_hash = hashlib.sha256(f"{user_id}-{filename}-{datetime.utcnow().isoformat()}".encode()).hexdigest()[:12]
    base = f"{folder}/{user_id}/{file_hash}"
    return f"{base}.{ext}" if ext else base

def get_public_url(file_key: str) -> str:
    return f"{settings.S3_PUBLIC_BASE_URL}/{settings.S3_BUCKET_UPLOADS}/{file_key}"

def delete_file(file_key: str):
    s3 = get_s3_client()
    s3.delete_object(Bucket=settings.S3_BUCKET_UPLOADS, Key=file_key)
