# Software Brava — Wiki Oficial (SAMU 192 Joinville)

Bem-vindo à documentação técnica em formato **Wiki** do **Software Brava**, sistema desenvolvido para digitalizar e gerenciar o atendimento pré-hospitalar móvel (APH) do **SAMU 192** e o painel administrativo de gestão de frotas, equipes e indicadores.

---

## Visão Geral

O **Software Brava** integra dois mundos em uma plataforma unificada:
1. **Aplicação Assistencial (Flutter Web / Mobile):** preenchimento rápido da Ficha de Atendimento Digital nas ambulâncias (inclusive com suporte offline e sincronização idempotente), avaliação clínica, escala de Glasgow, protocolo de AVC, folha de gastos de materiais e assinatura.
2. **Painel Administrativo & API REST (FastAPI + PostgreSQL):** controle gerencial de atendimentos, gestão de viaturas/bases/profissionais, exportação de PDF (`ReportLab`), auditoria LGPD e integração com a API da Prefeitura Municipal.

---

## Stack Tecnológica

| Camada | Tecnologia | Função |
| :--- | :--- | :--- |
| **Front-end** | Flutter (Dart) + `Provider` + `Dio` | Interface Web e Mobile/Tablet |
| **Proxy Reverso** | Nginx (`:8080`) | Servir bundle Flutter Web, cache, CSP e proxy `/api/` |
| **Back-end** | FastAPI (Python 3.13) + Uvicorn | API RESTful, regras clínicas, PDF e integrações |
| **ORM & Migrations** | SQLAlchemy 2 + Alembic | Mapeamento relacional e evolução de schema |
| **Banco de Dados** | PostgreSQL (prod) / SQLite (dev) | Persistência transacional (ACID) |
| **Segurança** | `bcrypt`, `PyJWT`, `slowapi`, HMAC-SHA256 | Autenticação, RBAC, rate limit e LGPD |
| **Qualidade & CI/CD** | `pytest`, `flutter test`, GitHub Actions, SonarQube Cloud | Testes automatizados, cobertura e SAST |
| **Infra & Observabilidade** | AWS EC2 (`sa-east-1`), Docker, Cloudflare Tunnel, Prometheus, Grafana | Hospedagem, HTTPS e métricas em tempo real |

---

## Navegação da Wiki

* [Arquitetura e Decisões Técnicas](Arquitetura.md)
* [Configuração e Ambiente Local](Configuracao-e-Ambiente.md)
* [Modelo de Dados, Regras Clínicas e API](Modelo-de-Dados-e-API.md)
* [Autenticação, Segurança e LGPD](Autenticacao-Seguranca-e-LGPD.md)
* [Testes, CI/CD e Qualidade (SonarQube Cloud)](Testes-CI-CD-e-Qualidade.md)
* [Deploy na AWS, Cloudflare Tunnel e Observabilidade](Deploy-AWS-e-Observabilidade.md)

---

> **Repositório:** `Madu3304/Software_brava` • **Região de Produção:** AWS São Paulo (`sa-east-1`)
