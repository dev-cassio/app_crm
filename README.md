# CRM

Base Django para projeto de gestão empresarial (CRM).

**Status:** projeto **em desenvolvimento** — o MVP descrito em `docs/first_prd.md` ainda não está concluído; APIs, telas e regras podem mudar até o primeiro release estável.

## Documentação de produto e pré-código

- **Índice:** [`docs/README.md`](docs/README.md)
- **PRD do MVP (referência principal):** [`docs/first_prd.md`](docs/first_prd.md)
- **Decisões técnicas e checklist pré-sprint:** [`docs/checklist_pre_codigo.md`](docs/checklist_pre_codigo.md)

## Stack técnica

- Python: `>=3.14,<4.0`
- Django: `>=6.0.3,<7.0`
- Interface: **Bootstrap 5** em templates Django (SSR)
- Banco em desenvolvimento: **SQLite** (padrão)
- Banco alvo em **produção:** **PostgreSQL** — `postgres:17.6-bookworm` via Docker Compose no ambiente local
- Estáticos em deploy containerizado: **WhiteNoise** (planejado; ver `docs/checklist_pre_codigo.md`)
- Uploads (`MEDIA`): disco local; em Docker usar **volume persistente** no `MEDIA_ROOT` (sem S3 na fase inicial)
- Ambiente/dependências: `uv`
- Lint/format Python: `ruff`
- Lint/format templates: `djlint`
- Testes: `pytest` + `pytest-django`

## Estrutura de pastas

```text
.
├── apps_django/          # Projeto Django e apps de borda
│   ├── contas/           # App de autenticação (usuário por e-mail)
│   ├── settings.py
│   ├── urls.py
│   └── ...
├── core/                 # Regras de negócio puras (inicia vazio)
│   └── services/
├── tests/                # Testes
│   └── borda_django/     # Testes de borda Django
├── deploy/               # Docker e Compose
├── templates/            # Templates Django
├── static/               # Assets estáticos
└── manage.py
```

## Setup local

1. Copie o arquivo de variáveis de ambiente:
   ```bash
   cp .env-sample .env
   ```

2. Instale as dependências de desenvolvimento:
   ```bash
   make install-dev
   ```

3. Execute as migrações:
   ```bash
   make migrate
   ```

4. Crie um superusuário:
   ```bash
   uv run python manage.py createsuperuser
   ```

## Rodar a aplicação

```bash
make run
```

A aplicação estará disponível em `http://localhost:8000`.

## Testes

```bash
make test           # todos os testes
make test-borda     # testes de borda Django
make test-cov       # com cobertura
```

## Lint e formatação

```bash
make lint
make format
```

## Depuração

O projeto inclui `.vscode/launch.json` configurado para depurar o `runserver` com **debugpy**.

Certifique-se de que o interpretador Python do VS Code aponta para o `.venv` criado pelo `uv`.

## Pre-commit

Para instalar os ganchos:

```bash
make pre-commit-install
```

Para executar manualmente:

```bash
make pre-commit-run
```

## Docker Compose (PostgreSQL local)

Para usar PostgreSQL no desenvolvimento, ajuste no `.env`:

```env
DATABASE_ENGINE=postgresql
DB_NAME=crm
DB_USER=crm
DB_PASSWORD=crm
DB_HOST=localhost
DB_PORT=5432
```

Suba o container:

```bash
make up-db
```

Derrube:

```bash
make down-db
```

## Autenticação por e-mail

O app `contas` substitui o modelo de usuário padrão do Django para usar **e-mail** como credencial de login.

- `USERNAME_FIELD = 'email'`
- `createsuperuser` solicita apenas e-mail, nome e senha
- O campo `username` é preenchido automaticamente com o e-mail
- Backend customizado `EmailBackend` permite autenticação por e-mail

## Variáveis de ambiente

Consulte `.env-sample` para a lista completa de variáveis necessárias.
