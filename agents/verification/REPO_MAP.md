# Repository Map - The Village

## Repository Overview
**Type**: Monorepo (pnpm workspace)
**Primary Language**: TypeScript (web) + Python (api)
**Architecture**: Microservices with Docker Compose

## Module Breakdown

### `/apps/api` - FastAPI Backend
**Purpose**: REST API server for The Village platform
**Stack**: Python 3.11, FastAPI, SQLAlchemy, Pydantic
**Key Components**:
- `main.py` - Application entry point
- `api/` - Route handlers (auth, ideas, invites, playlists, etc.)
- `models/` - SQLAlchemy ORM models
- `schemas/` - Pydantic validation schemas
- `core/` - Shared utilities (config, database, security, storage)
- `worker.py` - Background job processor (Redis/RQ)
- `alembic/` - Database migrations

### `/apps/web` - Next.js Frontend
**Purpose**: Web UI for The Village
**Stack**: Next.js 14 (App Router), TypeScript, Tailwind CSS
**Key Components**:
- `src/app/` - Next.js app directory pages
- `src/components/` - Reusable UI components
- `src/lib/` - Client utilities and API integration
- `public/` - Static assets

### `/docs` - Documentation
**Purpose**: Project documentation and policies
**Contents**: Architecture, contributing guides, legal docs, operations

### `/scripts` - Utility Scripts
**Purpose**: Build and maintenance automation
- `gen-sbom.sh` - Generate software bill of materials
- `launch_multi_agents.sh` - Agent orchestration

### `/agents` - AI Agent Artifacts
**Purpose**: Orchestration and verification outputs
**Structure**:
- `reports/` - Diagnostic reports by module
- `tickets/` - Implementation tickets
- `verification/` - Test verification reports
- `templates/` - Document templates
- `status/` - Project status tracking

### `/worktrees` - Git Worktrees
**Purpose**: Parallel development branches
**Contents**: Feature branches for different agents

## Key Configuration Files

### Root Level
- `docker-compose.yml` - Service orchestration
- `pnpm-workspace.yaml` - Monorepo workspace config
- `turbo.json` - Turborepo build pipeline
- `package.json` - Root package scripts
- `Makefile` - Common development tasks
- `.github/workflows/ci.yml` - CI/CD pipeline

### API Configuration
- `pyproject.toml` - Python project config (Black, coverage)
- `requirements.txt` - Python dependencies
- `alembic.ini` - Database migration config
- `Dockerfile` & `Dockerfile.worker` - Container definitions

### Web Configuration
- `next.config.js` - Next.js configuration
- `tsconfig.json` - TypeScript config
- `tailwind.config.ts` - Tailwind CSS config
- `postcss.config.js` - PostCSS config
- `vitest.config.ts` - Vitest test runner
- `playwright.config.ts` - E2E test config

## Test Infrastructure

### API Tests
- Location: `/apps/api/tests/`
- Framework: pytest
- Coverage: pytest-cov (75.87% current)
- Key tests:
  - `test_auth_invite.py` - Authentication and invites
  - `test_ideas_licenses.py` - Content licensing

### Web Tests
- Unit tests: `/apps/web/tests/` (Vitest)
- E2E tests: `/apps/web/tests-e2e/` (Playwright)
- Coverage: Configured in vitest.config.ts

## Build and Deployment

### Docker Services
1. **postgres** - PostgreSQL database
2. **redis** - Cache and job queue
3. **minio** - S3-compatible object storage
4. **api** - FastAPI application
5. **worker** - Background job processor
6. **web** - Next.js frontend

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Jobs**:
  - API linting (Black, isort, mypy)
  - API tests with coverage
  - Web build and Playwright tests
- **Triggers**: PR and main branch pushes

### Build Commands
```bash
# Full stack
docker compose up

# API only
cd apps/api && python -m pytest

# Web only
cd apps/web && pnpm test

# Workspace install
pnpm install
```

## Environment Requirements
- Node.js 20+
- Python 3.11+
- Docker & Docker Compose
- pnpm (via corepack)

## Current State
- **Branch**: feature/TICKET-20241214-coverage-tooling
- **Status**: All critical issues resolved (per PROJECT_STATUS.md)
- **Test Coverage**: API 75.87%, Web tests passing

---
Generated: 2025-01-14

## Environment Information
**Capture Date**: Sun Sep 14 22:35:03 BST 2025
**OS**: Darwin Olivers-MacBook-Pro.local 24.6.0 Darwin Kernel Version 24.6.0: Mon Jul 14 11:30:40 PDT 2025; root:xnu-11417.140.69~1/RELEASE_ARM64_T8132 arm64
**CPU**: Apple M4
**Memory**: 16 GB

### Toolchain Versions
- **Node.js**: v20.19.5
- **npm**: 10.8.2
- **pnpm**: 8.14.0
- **Python**: Python 3.11.9
- **pip**: 25.2
- **Docker**: 28.4.0
- **Docker Compose**: v2.39.2-desktop.1
- **Git**: 2.51.0
