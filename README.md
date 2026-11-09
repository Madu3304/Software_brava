## Software_brava

A seguir do documentário: https://pt.overleaf.com/read/qgdhvyyrzbqh#8cad4d

Este projeto busca solucionar um problema real e atual identificado nas Unidades Básicas de Saúde, no sistema do SAMU de Joinville, propondo o desenvolvimento de uma solução tecnológica que auxilie na melhoria dos processos e na qualidade do atendimento prestado à população.

## Identificação

- Título do Projeto: Software Brava
- Linha de Projeto: Aplicativo.
- Autor: Maria Eduarda Nunes
- Data da Proposta: 10/03/2026
- Versão: 1.0

## Tecnologias previstas

As tecnologias ainda podem ser ajustadas ao longo do projeto, mas inicialmente estão previstas:

- **Backend:** Python 3.13 + SQLAlchemy 2.0
- **Banco de dados:** PostgreSQL
- **Frontend/Admin:** Flutter (previsto)
- **Controle de tarefas:** Trello

## Como rodar com Docker (Projeto Completo: Frontend + Backend)

### Opção 1: Imagem Docker Única (Frontend Flutter Web + Backend FastAPI + SQLite)

Na raiz do repositório, construa a imagem unificada e inicie o container:

```bash
docker build -t software-brava .
docker run -d --name software-brava -p 8080:8080 -p 8000:8000 -v brava_data:/app/data software-brava
```

- **Aplicação Web (Painel Administrativo + Ficha APH):** http://localhost:8080
- **API Backend (Swagger / OpenAPI):** http://localhost:8000/docs (ou http://localhost:8080/docs)
- **Credenciais iniciais:**
  - **Administrador (Dashboard Web):** login `admin` | senha `admin123`
  - **Equipe de Campo (Ficha APH):** login `enfermeiro` | senha `brava123`

### Opção 2: Docker Compose (PostgreSQL + Backend + Frontend)

```bash
docker compose up --build -d
```

---

## Como rodar localmente (sem Docker)

### 1. Criar o banco

```sql
CREATE DATABASE brava;
```

### 2. Instalar as dependências

```bash
cd Backend
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Linux/macOS
pip install -r requirements.txt
```

### 3. Configurar a conexão

```bash
cp .env.example .env
```

Preencha `DATABASE_URL` com os dados do seu PostgreSQL local. A aplicação
não sobe sem essa variável — é proposital.

### 4. Criar as tabelas

```bash
python main.py
```

Cria as sete tabelas via SQLAlchemy ORM (`usuario`, `unidade_movel`,
`paciente`, `hospital_destino`, `ficha_atendimento`, `avaliacao_clinica`,
`log_auditoria`) e executa uma consulta de teste.

## Estrutura

```
Backend/
  database.py       Conexão, Session e Base do SQLAlchemy
  main.py           Criação das tabelas e teste de conexão
  models/           Um arquivo por entidade do modelo de dados
ModeloC4/           Diagramas de arquitetura (níveis 1 a 4)
RFC/                Documento de requisitos e SDD
```