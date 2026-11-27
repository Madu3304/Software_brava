# Testes, CI/CD e Qualidade

## Testes Automatizados e Cobertura

### Back-end (`Backend/tests/` e `Backend/test_server.py`)
8 suítes em **`pytest`** cobrindo:
* `test_login.py` — autenticação, rate limit e bloqueios
* `test_permissoes.py` — RBAC e proteção BOLA/IDOR entre usuários
* `test_validacoes_clinicas.py` — sinais vitais, Glasgow, horários e CPF
* `test_cadastros_usuarios.py` — gestão de usuários e profissionais
* `test_pdf_e_fichas.py` — criação de fichas e geração de PDF (`ReportLab`)
* `test_soft_delete.py` — exclusão lógica segura
* `test_sync_idempotente.py` — sincronização offline sem duplicação (`uuid_offline`)
* `test_servicos_e_integracoes.py` — Prefeitura, Ollama e integrações

**Executar com relatório de cobertura:**
```bash
cd Backend
pytest --cov=. --cov-report=xml --cov-report=term
```
* **Cobertura medida (`Backend/coverage.xml`):** **89,85%** (`1947 / 2167` linhas).

---

### Front-end (`Frontend/test/`)
17 arquivos de testes unitários e de widget (`models/`, `services/`, `utils/`, `views/`).

**Executar com relatório de cobertura:**
```bash
cd Frontend
flutter test --coverage
```
* **Cobertura medida (`Frontend/coverage/lcov.info`):** **73,95%** (`4809 / 6503` linhas).

---

## Pipeline CI/CD (`.github/workflows/ci.yml`)

Disparado automaticamente em `push` (`main`, `Dev`, `DevFrontEnd`) e `pull_request` (`main`), com dois jobs em paralelo no `ubuntu-latest`:

| Job | Etapas | Comportamento em Falha |
| :--- | :--- | :--- |
| **`backend-ci`** | `checkout` (SHA fixado) → `setup-python 3.13` → `pip install` → `ruff` + `bandit` (`\|\| true`) → `python test_server.py` | Falha nos testes bloqueia o check do PR/commit |
| **`frontend-ci`** | `checkout` (SHA fixado) → `flutter-action` → `flutter pub get` → `flutter analyze` (`\|\| true`) → `flutter test` | Falha em `flutter test` bloqueia o check |

*(Para alterar o pipeline para execução apenas manual, basta trocar o gatilho `on:` para `workflow_dispatch:`.)*

---

## Análise Estática Contínua (SonarQube Cloud)

O repositório `Madu3304/Software_brava` é integrado ao **SonarQube Cloud** (`sonarcloud.io`) para inspeção automática de:
* Vulnerabilidades e boas práticas de Segurança (GitHub Actions fixadas por SHA, Dockerfile sem cópia recursiva irrestrita, Android `allowBackup="false"` e ofuscação R8);
* Confiabilidade (`lang="pt-BR"` em `index.html`, detecção de bugs);
* Manutenibilidade e Duplicação de código (`0,0%` após remoção de pastas espelho no `.gitignore`).
