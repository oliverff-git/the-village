.PHONY: setup format lint typecheck test coverage build run docker-up docker-down sbom

setup:
	pnpm install
	pre-commit install || true

format:
	pnpm format || true
	cd apps/api && black .

lint:
	pnpm lint || true
	cd apps/api && ruff .

typecheck:
	cd apps/api && mypy . || true

test:
	cd apps/api && pytest -q
	cd apps/web && pnpm test -- --run

coverage:
	cd apps/api && pytest -q --cov=. --cov-report=term-missing

build:
	pnpm build

run:
	docker compose up -d

docker-up:
	docker compose up -d

docker-down:
	docker compose down -v

sbom:
	./scripts/gen-sbom.sh
