.PHONY: setup format lint typecheck test coverage build run docker-up docker-down sbom

setup:
	corepack enable
	pnpm -w install
	pre-commit install || true

format:
	pnpm -w format || true
	cd apps/api && black .

lint:
	pnpm -w lint || true
	cd apps/api && ruff .

typecheck:
	cd apps/api && mypy . || true

test:
	cd apps/api && pytest -q || true
	cd apps/web && pnpm test -- --run || true

coverage:
	cd apps/api && pytest --cov=. --cov-report=term-missing --cov-fail-under=85

build:
	pnpm -w build

run:
	docker compose up -d

docker-up:
	docker compose up -d

docker-down:
	docker compose down -v

sbom:
	./scripts/gen-sbom.sh
