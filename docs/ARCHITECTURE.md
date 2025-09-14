# Architecture (MVP)

Monorepo: **apps/api** (FastAPI + Postgres + Redis + RQ), **apps/web** (Next.js 14).  
Media: MinIO (S3 compatible) presigned uploads; worker stubs for audio pipeline.  
Metrics: Prometheus `/metrics`. Logs: JSON with request IDs.
