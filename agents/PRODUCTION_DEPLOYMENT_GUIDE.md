# Production Deployment Guide - The Village

## Overview
This guide provides step-by-step instructions for deploying The Village to production environments.

## Prerequisites

### Required Tools
- Docker 20.10+ & Docker Compose v2+
- Git
- Domain name with DNS control
- SSL certificates (or use Let's Encrypt)
- Cloud provider account (AWS/GCP/Azure) or VPS

### Required Resources
- **Minimum Server Specs**:
  - CPU: 2+ cores
  - RAM: 4GB minimum (8GB recommended)
  - Storage: 20GB+ (for Docker images and data)
  - Network: Public IP with ports 80/443 open

### Required Secrets
```bash
# Create .env.production file with:
POSTGRES_PASSWORD=<strong-password>
REDIS_PASSWORD=<strong-password>
JWT_SECRET=<generated-secret>
S3_ACCESS_KEY=<minio-access-key>
S3_SECRET_KEY=<minio-secret-key>
ALLOWED_ORIGINS=https://yourdomain.com
```

## Pre-Deployment Checklist

### Code Preparation
- [ ] All tests passing locally
- [ ] No linting errors
- [ ] Production builds tested
- [ ] Secrets configured in .env.production
- [ ] Docker images built and tagged

### Infrastructure
- [ ] Server provisioned and accessible
- [ ] Docker & Docker Compose installed
- [ ] Firewall configured (80, 443, 22)
- [ ] DNS records pointing to server
- [ ] SSL certificates ready

## Deployment Steps

### 1. Initial Server Setup
```bash
# SSH into your server
ssh user@your-server-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### 2. Clone Repository
```bash
# Clone the repository
git clone https://github.com/[your-org]/the-village.git
cd the-village

# Checkout production branch
git checkout main  # or your production branch
```

### 3. Configure Production Environment
```bash
# Copy production environment template
cp .env.example .env.production

# Edit with production values
nano .env.production

# Required variables:
NODE_ENV=production
DATABASE_URL=postgresql://village_user:${POSTGRES_PASSWORD}@postgres:5432/thevillage
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/0
S3_ENDPOINT=https://your-s3-endpoint.com
ALLOWED_ORIGINS=https://yourdomain.com
JWT_SECRET=<generate-with-openssl-rand-base64-32>
```

### 4. Create Production Docker Compose
```yaml
# docker-compose.production.yml
services:
  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_DB: thevillage
      POSTGRES_USER: village_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U village_user -d thevillage"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  minio:
    image: minio/minio:latest
    restart: always
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${S3_ACCESS_KEY}
      MINIO_ROOT_PASSWORD: ${S3_SECRET_KEY}
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    image: the-village-api:prod
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      minio:
        condition: service_healthy
    env_file:
      - .env.production
    expose:
      - "8000"

  worker:
    image: the-village-api:prod
    restart: always
    command: python -m worker
    depends_on:
      - api
    env_file:
      - .env.production

  web:
    image: the-village-web:prod
    restart: always
    depends_on:
      - api
    environment:
      NEXT_PUBLIC_API_URL: https://api.yourdomain.com
    expose:
      - "3000"

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.production.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
      - api

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

### 5. Configure Nginx
```nginx
# nginx.production.conf
events {
    worker_connections 1024;
}

http {
    upstream api {
        server api:8000;
    }

    upstream web {
        server web:3000;
    }

    server {
        listen 80;
        server_name yourdomain.com api.yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.yourdomain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://web;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 6. Build and Deploy
```bash
# Build production images
docker build -f apps/api/Dockerfile -t the-village-api:prod apps/api
docker build -f apps/web/Dockerfile -t the-village-web:prod apps/web

# Run database migrations
docker-compose -f docker-compose.production.yml run --rm api alembic upgrade head

# Start services
docker-compose -f docker-compose.production.yml up -d

# Check status
docker-compose -f docker-compose.production.yml ps

# View logs
docker-compose -f docker-compose.production.yml logs -f
```

### 7. Post-Deployment Tasks
```bash
# Create admin user
docker-compose -f docker-compose.production.yml exec api python scripts/create_admin.py

# Initialize MinIO buckets
docker-compose -f docker-compose.production.yml exec minio mc config host add local http://localhost:9000 $S3_ACCESS_KEY $S3_SECRET_KEY
docker-compose -f docker-compose.production.yml exec minio mc mb local/uploads
docker-compose -f docker-compose.production.yml exec minio mc policy set public local/uploads

# Set up automated backups
crontab -e
# Add: 0 2 * * * docker exec postgres pg_dump -U village_user thevillage > /backups/db_$(date +\%Y\%m\%d).sql
```

## Monitoring & Maintenance

### Health Checks
```bash
# Check all services
docker-compose -f docker-compose.production.yml ps

# Check specific service health
docker inspect the-village-api-1 | jq '.[0].State.Health'

# Monitor resource usage
docker stats

# Check logs for errors
docker-compose -f docker-compose.production.yml logs --tail=100 | grep ERROR
```

### Backup Procedures
```bash
# Database backup
docker exec postgres pg_dump -U village_user thevillage > backup.sql

# Media files backup
docker run --rm -v minio_data:/data -v $(pwd):/backup alpine tar czf /backup/minio_backup.tar.gz /data

# Full backup script
#!/bin/bash
BACKUP_DIR="/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
docker exec postgres pg_dump -U village_user thevillage > $BACKUP_DIR/database.sql
docker run --rm -v minio_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/minio.tar.gz /data
```

### Update Procedures
```bash
# Pull latest code
git pull origin main

# Rebuild images
docker build -f apps/api/Dockerfile -t the-village-api:prod apps/api
docker build -f apps/web/Dockerfile -t the-village-web:prod apps/web

# Run migrations
docker-compose -f docker-compose.production.yml run --rm api alembic upgrade head

# Restart services with zero downtime
docker-compose -f docker-compose.production.yml up -d --no-deps --build api
docker-compose -f docker-compose.production.yml up -d --no-deps --build worker
docker-compose -f docker-compose.production.yml up -d --no-deps --build web
```

## Troubleshooting

### Common Issues

#### 1. Services Won't Start
```bash
# Check logs
docker-compose -f docker-compose.production.yml logs [service-name]

# Check resource usage
docker system df
df -h

# Clean up if needed
docker system prune -a
```

#### 2. Database Connection Issues
```bash
# Test connection
docker-compose -f docker-compose.production.yml exec postgres psql -U village_user -d thevillage

# Check environment variables
docker-compose -f docker-compose.production.yml exec api env | grep DATABASE_URL
```

#### 3. SSL Certificate Issues
```bash
# Test SSL
openssl s_client -connect yourdomain.com:443

# Renew Let's Encrypt
certbot renew --nginx
```

### Emergency Procedures

#### Rollback
```bash
# Tag current version before update
docker tag the-village-api:prod the-village-api:backup
docker tag the-village-web:prod the-village-web:backup

# Rollback if needed
docker tag the-village-api:backup the-village-api:prod
docker tag the-village-web:backup the-village-web:prod
docker-compose -f docker-compose.production.yml up -d
```

#### Data Recovery
```bash
# Restore database
docker exec -i postgres psql -U village_user thevillage < backup.sql

# Restore media files
docker run --rm -v minio_data:/data -v $(pwd):/backup alpine tar xzf /backup/minio_backup.tar.gz -C /
```

## Security Considerations

### Essential Security Steps
1. **Use strong passwords** for all services
2. **Enable firewall** (ufw or iptables)
3. **Regular updates** of OS and Docker
4. **SSL/TLS** for all public endpoints
5. **Regular backups** with offsite storage
6. **Monitor logs** for suspicious activity
7. **Implement rate limiting** in Nginx

### Recommended Hardening
```bash
# Fail2ban for SSH protection
sudo apt install fail2ban

# Automatic security updates
sudo apt install unattended-upgrades

# Docker security scanning
docker scan the-village-api:prod
docker scan the-village-web:prod
```

## Performance Optimization

### Quick Wins
1. **Enable caching** in Nginx
2. **Use CDN** for static assets
3. **Enable gzip** compression
4. **Optimize images** before upload
5. **Database indexing** for common queries

### Monitoring Setup
```bash
# Install monitoring stack (optional)
docker run -d --name prometheus -p 9090:9090 prom/prometheus
docker run -d --name grafana -p 3001:3000 grafana/grafana
```

## Support & Maintenance

### Regular Tasks
- **Daily**: Check logs and service health
- **Weekly**: Review resource usage and backups
- **Monthly**: Security updates and performance review
- **Quarterly**: Disaster recovery test

### Getting Help
1. Check application logs first
2. Review this deployment guide
3. Check Docker and service documentation
4. Search error messages online
5. Contact development team if needed

---
Guide Version: 1.0
Last Updated: 2025-09-14
Compatible with: The Village v1.0
