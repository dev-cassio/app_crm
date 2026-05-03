.PHONY: help install install-dev run migrate makemigrations lint format test test-borda test-cov pre-commit-install pre-commit-run up down build up-db down-db

help:
	@echo "Comandos disponíveis:"
	@echo "  install         - instala dependências de produção com uv"
	@echo "  install-dev     - instala todas as dependências (inclui dev)"
	@echo "  run             - roda o servidor de desenvolvimento"
	@echo "  migrate         - executa migrações do Django"
	@echo "  makemigrations  - cria novas migrações"
	@echo "  lint            - executa ruff check e djlint --check"
	@echo "  format          - executa ruff format e djlint --reformat"
	@echo "  test            - roda todos os testes"
	@echo "  test-borda      - roda testes de borda Django"
	@echo "  test-cov        - roda testes com cobertura"
	@echo "  pre-commit-install - instala ganchos do pre-commit"
	@echo "  pre-commit-run  - executa pre-commit em todos os arquivos"
	@echo "  up              - sobe PostgreSQL (perfil Compose postgres)"
	@echo "  down            - derruba serviços Compose"
	@echo "  build           - rebuilda imagens Docker dos serviços"
	@echo "  up-db           - igual a up (PostgreSQL)"
	@echo "  down-db         - para o container PostgreSQL"

install:
	uv sync

install-dev:
	uv sync --all-groups

run:
	uv run python manage.py runserver 0.0.0.0:$${PORT:-8000}

migrate:
	uv run python manage.py migrate

makemigrations:
	uv run python manage.py makemigrations

lint:
	uv run ruff check .
	uv run djlint --check --profile=django templates

format:
	uv run ruff format .
	uv run djlint --reformat --profile=django templates

test:
	uv run pytest

test-borda:
	uv run pytest tests/borda_django

pre-commit-install:
	uv run pre-commit install

pre-commit-run:
	uv run pre-commit run --all-files

test-cov:
	uv run pytest --cov=core --cov=apps_django --cov-report=term-missing

up:
	docker compose -f deploy/docker-compose.yml --env-file .env --profile postgres up -d db

down:
	docker compose -f deploy/docker-compose.yml --env-file .env down --remove-orphans

build:
	docker compose -f deploy/docker-compose.yml --env-file .env build

up-db: up

down-db:
	docker compose -f deploy/docker-compose.yml --env-file .env --profile postgres stop db
