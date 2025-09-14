from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Database
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "thevillage"
    POSTGRES_USER: str = "village_user"
    POSTGRES_PASSWORD: str = ""

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # S3/MinIO
    S3_ENDPOINT: str = "http://localhost:9000"
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadmin"
    S3_BUCKET_UPLOADS: str = "village-uploads"
    S3_REGION: str = "us-east-1"
    S3_PUBLIC_BASE_URL: str = "http://localhost:9000"

    # JWT
    JWT_SECRET: str = "change_me_very_secret_key"
    JWT_REFRESH_SECRET: str = "change_me_refresh_secret"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # App
    APP_BASE_URL: str = "http://localhost:3000"
    API_BASE_URL: str = "http://localhost:8000"

    # ACRCloud (Optional)
    ACRCLOUD_HOST: str = ""
    ACRCLOUD_ACCESS_KEY: str = ""
    ACRCLOUD_ACCESS_SECRET: str = ""

    # Rate Limiting
    RATE_LIMIT_SIGNUP_PER_DAY: int = 10
    RATE_LIMIT_INVITES_PER_USER: int = 5
    RATE_LIMIT_UPLOADS_PER_HOUR: int = 20

    # Admin bootstrap
    ADMIN_EMAIL: str = "admin@thevillage.local"
    ADMIN_PASSWORD: str = "change_me_admin_password"

    @property
    def DATABASE_URL(self) -> str:
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def CORS_ORIGINS(self) -> List[str]:
        origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
        return [origin.strip() for origin in origins]

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
