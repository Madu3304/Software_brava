# Configuração e Ambiente

## Conexão com o Banco de Dados (`Backend/database.py`)

A conexão é configurada via variável `DATABASE_URL`:
* **Desenvolvimento local:** se `DATABASE_URL` não for definida, o sistema utiliza automaticamente o fallback SQLite `sqlite:///./brava.db`.
* **Produção (Docker / AWS):** utiliza PostgreSQL (`postgresql+psycopg2://<user>:<password>@127.0.0.1:5432/brava`).

### Diferenças entre Desenvolvimento e Produção

| Comportamento | `APP_ENV=development` | `APP_ENV=production` |
| :--- | :--- | :--- |
| **Seed inicial (`seed_initial_data`)** | Executado automaticamente no startup | Ignorado (execução manual controlada) |
| **Swagger / Redoc (`/docs`, `/redoc`)** | Habilitados | Desabilitados no FastAPI e bloqueados (`404`) no Nginx |
| **`JWT_SECRET_KEY` ausente** | Gera chave efêmera com aviso | Falha no startup (`RuntimeError`) |
| **`CPF_HMAC_KEY` ausente** | Usa fallback de desenvolvimento com aviso | Falha no startup (`RuntimeError`) |
| **Hashes legados SHA-256 sem sal** | Permitidos com migração automática | Bloqueados por padrão (`ALLOW_LEGACY_SHA256=false`) |

---

## Variáveis de Ambiente Principais

Consulte o template completo em `Backend/.env.example`:

| Variável | Obrigatória em Prod | Descrição |
| :--- | :---: | :--- |
| `APP_ENV` | Sim | `development` ou `production` |
| `DATABASE_URL` / `POSTGRES_*` | Sim | String de conexão e credenciais do PostgreSQL |
| `JWT_SECRET_KEY` | Sim | Chave secreta para assinatura de tokens JWT (`HS256`) |
| `CPF_HMAC_KEY` | Sim | Chave HMAC-SHA256 para pseudonimização de CPF (LGPD) |
| `ADMIN_PASSWORD` / `EQUIPE_PASSWORD` | No seed | Senhas iniciais dos usuários criados pelo `seed.py` |
| `SEED_TROCAR_SENHA` | Não | Exige troca de senha no primeiro login (`true`/`false`) |
| `CORS_ORIGINS` | Sim | Origens web permitidas (ex.: `https://bravasamu.com.br`) |
| `LOGIN_RATE_LIMIT` | Não | Limite de tentativas no login (ex.: `10/minute`) |
| `PREFEITURA_API_URL` / `TOKEN` | Não | Integração externa com a Prefeitura Municipal |
| `OLLAMA_BASE_URL` / `OLLAMA_MODEL` | Não | Integração com IA local (Ollama) |
| `GRAFANA_ADMIN_USER` / `PASSWORD` | No Grafana | Credenciais do painel Grafana |

> Em produção na AWS EC2, todas as variáveis ficam armazenadas exclusivamente no arquivo `.env` (`chmod 600 .env`), fora do controle de versão (`.gitignore`).

---

## Como Rodar Localmente (Após Clonar o Repositório)

### Opção 1 — Localmente sem Docker (Python + Flutter)
1. **Back-end:**
   ```bash
   cd Backend
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   python main.py
   ```
   *(Com `APP_ENV=development` no `.env` ou usando o fallback padrão, o servidor sobe em `http://127.0.0.1:8000` e cria `brava.db`.)*

2. **Front-end:**
   ```bash
   cd Frontend
   flutter pub get
   flutter run -d chrome
   ```

### Opção 2 — Via Docker Compose
1. Crie o arquivo `.env` na raiz com base em `Backend/.env.example`.
2. Suba o serviço principal:
   ```bash
   docker compose up -d --build software-brava
   ```
3. Acesse `http://localhost:8080`.
