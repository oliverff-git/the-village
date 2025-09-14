# The Village - Web Application

## Setup Instructions

### First Time Setup
```bash
# IMPORTANT: Install dependencies at workspace root level
cd ../.. # Navigate to repository root
pnpm install

# This installs all workspace dependencies including platform-specific binaries
```

### Running Tests

#### Unit Tests
```bash
cd apps/web
pnpm test          # Run in watch mode
pnpm test -- --run # Run once and exit
```

#### E2E Tests
```bash
cd apps/web
pnpm test:e2e      # Requires Docker services running
```

## Troubleshooting

### "Cannot find module @rollup/rollup-darwin-*" Error
This occurs when dependencies are not properly installed at the workspace level.

**Solution**:
```bash
# From repository root (not apps/web)
cd ../..
pnpm install
```

**Why this happens**: Running `pnpm install` inside apps/web alone is insufficient because pnpm workspaces handle platform-specific optional dependencies at the workspace root level.

### Web Service Not Accessible
If http://localhost:3000 returns connection refused:

1. Check Docker services: `docker compose ps`
2. Check web logs: `docker compose logs web --tail 50`
3. Restart if needed: `docker compose restart web`

## Development Workflow

1. Always run `pnpm install` from repository root after pulling changes
2. Use `pnpm test -- --run` for CI-like test execution
3. Run `pnpm test:e2e` before pushing to catch integration issues

## Build for Production
```bash
npm run build
# Output in .next/ directory
```

