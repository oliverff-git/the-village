# The Village Repository Module Map

## Repository Structure

### Core Applications
1. **apps/api** - FastAPI Backend
   - **Main Components**:
     - `api/` - API endpoints (auth, ideas, invites, legal, moderation, mood, playlists, reports, uploads)
     - `core/` - Core utilities (config, database, queue, security, storage, types)
     - `models/` - SQLAlchemy models
     - `schemas/` - Pydantic schemas
     - `workers/` - Background job workers
     - `alembic/` - Database migrations
   - **Key Files**:
     - `main.py` - FastAPI application entry
     - `worker.py` - RQ worker entry
     - `pyproject.toml` - Python project config
     - `requirements.txt` - Dependencies

2. **apps/web** - Next.js Frontend
   - **Main Components**:
     - `src/app/` - Next.js app router pages
     - `src/components/` - React components
     - `src/lib/` - Utilities and API client
   - **Key Files**:
     - `package.json` - Node dependencies
     - `next.config.js` - Next.js configuration
     - `tailwind.config.ts` - Styling configuration

### Infrastructure
- **Docker**:
  - `docker-compose.yml` - Local development stack
  - `apps/api/Dockerfile` - API container
  - `apps/api/Dockerfile.worker` - Worker container
  - `apps/web/Dockerfile` - Web container

### Documentation
- `docs/` - Project documentation
  - `ARCHITECTURE.md` - System design
  - `DATA_MODEL.md` - Database schema
  - `OPERATIONS.md` - Deployment guide
  - Various policy documents

### Development Tools
- **Scripts**:
  - `bootstrap_village.sh` - Initial setup
  - `implementation.sh` - Development helpers
  - `scripts/gen-sbom.sh` - SBOM generation
  - `scripts/launch_multi_agents.sh` - Multi-agent coordination

### Testing
- **API Tests**: `apps/api/tests/`
  - `test_auth_invite.py`
  - `test_ideas_licenses.py`
- **Web Tests**: 
  - `apps/web/tests/` - Unit tests
  - `apps/web/tests-e2e/` - E2E tests

### Agent Work Areas
- `agents/` - Multi-agent collaboration space
- `worktrees/` - Git worktrees for parallel development
  - `claude/` - Claude agent work (auth-invites, ideas-bysa, python-skeleton)
  - `codex/` - Codex agent work (ci-e2e, observability, precommit-quality, supplychain)

## Technology Stack
- **Backend**: Python 3.x, FastAPI, SQLAlchemy, Alembic, Redis, RQ
- **Frontend**: TypeScript, Next.js 14, React, Tailwind CSS
- **Database**: PostgreSQL (production), SQLite (testing)
- **Storage**: MinIO (S3-compatible)
- **Monitoring**: Prometheus metrics
- **Testing**: pytest, Vitest, Playwright
