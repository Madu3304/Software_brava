# Análise Completa — Portfólio Software Brava vs. Repositório Atual

**Documento de referência:** Portfólio Mobile — *Software Brava* (Versão 1.0, 10/03/2026)  
**Repositório analisado:** `Software_brava` (`Frontend/`, `Backend/`, `docker/`, `Dockerfile`)

---

## 1. Resumo Executivo

O projeto implementado no repositório atende **à maior parte da arquitetura, fluxo operacional, regras de segurança e requisitos funcionais** descritos no Portfólio (incluindo itens que estavam listados como *Melhorias Futuras* na Seção 9.5, como assinatura digital na tela e autenticação individual).

Contudo, existem **divergências pontuais**, **módulos previstos no PDF ainda não finalizados no Frontend ou Infraestrutura** e **melhorias de alinhamento entre Banco/Backend e Frontend** que estão detalhadas abaixo.

---

## 2. Pontos que Estão de Acordo (PDF ↔ Projeto)

### 2.1 Arquitetura e Stack Tecnológica (Seções 5.1 a 5.4)
- **Frontend Mobile e Web em Flutter/Dart** (`Frontend/`): código unificado atendendo tanto ao fluxo assistencial (Mobile/Tablet) quanto ao painel administrativo (Web).
- **Backend API em Python + FastAPI + Pydantic + SQLAlchemy 2.0** (`Backend/`): estrutura modular em `controllers/`, `models/`, `services/`, `schemas.py` e `database.py` (RNF04).
- **Persistência Híbrida (Offline-First)** (`DatabaseHelper` + `DatabaseService` + `SyncService` ↔ `sync_controller.py`):
  - SQLite local no cliente com fila de pendências e sincronização em lote (`POST /api/sync/lote`) com deduplicação por `uuid_offline`.
  - Banco central relacional via SQLAlchemy com suporte a PostgreSQL/SQLite (`DATABASE_URL`) e migrations Alembic (`Backend/alembic/`).
- **Containerização Docker + Proxy Reverso Nginx** (`Dockerfile`, `docker/nginx.conf`, `docker/entrypoint.sh`): empacota Frontend Web + API FastAPI com proxy `/api/` para `127.0.0.1:8000/api/`.

### 2.2 Autenticação, Segurança, LGPD e Auditoria (Seção 6 e RNF02/RNF03/RNF05)
- **Login individual e RBAC (RN01 / RN13 / Seção 6.3 & 9.5)**:
  - Substituído o login genérico por viatura por autenticação individual com JWT (`PyJWT`) e redirecionamento por perfil (`ADMINISTRADOR` ➔ `WEB`; `ENFERMEIRO`, `TECNICO`, `CONDUTOR` ➔ `MOBILE`) em `security_service.py` e `auth_controller.py`.
  - Bloqueio de rotas por perfil via `exigir_perfil(...)` em `Backend/dependencies.py` e proteção de rotas no Frontend (`main.dart`).
- **Senhas com `bcrypt` (Seção 6.1 / 6.2)**:
  - `gerar_hash_senha` usa `bcrypt` com salt dinâmico e custo 12 (`BCRYPT_ROUNDS = 12`), com migração transparente de hashes legados no login.
- **Proteção contra SQL Injection e Validação Estrita (Seção 6.4 / RF03)**:
  - Uso exclusivo de ORM SQLAlchemy + schemas Pydantic (`schemas.py`) com validações clínicas (Glasgow, PA, BPM, O2, CPF Módulo 11).
- **Logs de Auditoria sem Dados Sensíveis de Saúde (Seção 6.5 / RNF05)**:
  - `registrar_auditoria` (`log_service.py`) grava apenas metadados (`acao`, `detalhes`, `id_usuario`, `ip_origem`, `data_hora`) e acesso restrito a `ADMINISTRADOR` (`GET /api/logs/`).
  - `POST /api/auth/logout` exige JWT (`Depends(get_usuario_atual)`), sem spoofing via query param.
- **Rate Limiting**: `slowapi` protegendo `/api/auth/login` e `/api/auth/token`.

### 2.3 Requisitos Funcionais Implementados (Seção 2.3)
- **RF01 / RF02 / RN04 (Registro Digital e Múltipla Escolha)**: Fluxo assistencial completo em etapas (`FichaAtendimentoView` ➔ `RegistroAtendimentoView` ➔ `DadosPacienteView` ➔ `AvaliacaoClinicaView` ➔ `AssinaturaPacienteView` ➔ `FolhaGastosView` ➔ `FolhaGastosMateriaisView` ➔ `ImpressaoSucessoView`), com botões/chips de múltipla escolha para triagem, viatura, Glasgow, Cincinnati, medicamentos e materiais.
- **RF03 / RN03 (Validação Automática)**: Validação de campos obrigatórios e formato de CPF (Módulo 11 no `onBlur` e no envio) no Frontend e Backend.
- **RF06 (Integração com a Prefeitura)**: `integration_service.py` + `sync_controller.py` com controle de `PENDENTE` / `ENVIADO` / `ERRO` e reenvio manual pelo Admin (`POST /api/sync/reenviar-pendentes`).
- **RF07 / RNF08 (Relatórios e PDF)**: Endpoint `GET /api/fichas/{id_ficha}/pdf` (`pdf_service.py` com ReportLab) e `PrintService` (`print_service.dart`) no Frontend conectado à `ImpressaoSucessoView`.
- **RF09 / RN05 (GPS)**: `GpsService` (`geolocator` + ViaCEP) capturando latitude, longitude e endereço na tela de dados do paciente.
- **RF10 (Cadastros pelo Administrador)**: Telas padronizadas para Médicos, Técnicos de Enfermagem, Socorristas e Unidades Móveis (`Frontend/lib/views/admin/cadastros/`) integradas ao `cadastro_controller.py`.
- **RF13 / RF14 / RF15 / RF16 (Métricas do Dashboard)**: `report_controller.py` e `report_service.py` calculando volume total, atendimentos do dia, distribuição por faixa etária, bairros com maior ocorrência e tempo médio de resposta, com filtros (`ano`, `mes`, `dia`, `unidade`) conectados ao `DashboardProvider`.

### 2.4 Itens Adicionais Implementados Além da Especificação v1.0
- **Assinatura Digital do Paciente + DocuSign** (`AssinaturaPacienteView` + `DocuSignService` + `docusign_controller.py`): atende à melhoria futura descrita na Seção 9.5 (*ZAPPZAIN / aceite com assinatura digital na tela*).
- **Folha de Gastos e Controle de Reposição de Materiais/Medicamentos**: `FolhaGastosView`, `FolhaGastosMateriaisView`, tabela `Utensilios` e endpoints `/api/fichas/reposicao`.

---

## 3. Pontos Diferentes, Faltantes ou que Precisam de Implementação/Correção

### 3.1 Requisitos Funcionais / Regras de Negócio Pendentes ou Parciais

1. **RF11 & RF12 — Indicação de "Unidade Parada" no início da ficha e Monitoramento de Paradas no Dashboard**
   - **No PDF:** RF11 exige informar *no início da ficha* se a unidade está parada e o motivo; RF12 exige exibir essas paradas no Dashboard.
   - **No Projeto:** O Backend já possui os campos `unidade_parada` e `motivo_unidade_parada` em `FichaAtendimento` e o endpoint `GET /api/reports/paradas-viaturas` (`report_controller.py`). Porém, no **Frontend**, `FichaAtendimentoView` (`ficha_atendimento_view.dart`) não possui o toggle/campo de unidade parada, e `DashboardOverviewScreen` não exibe um card consumindo `/api/reports/paradas-viaturas`.

2. **RN08 & Seção 4.1 / 6.3 — Consulta de Histórico de Fichas pelo Administrador**
   - **No PDF:** O Administrador deve poder consultar atendimentos anteriores / visualizar fichas registradas (sem alterar prontuários finalizados — RN07).
   - **No Projeto:** O Backend possui `GET /api/fichas/` e `GET /api/fichas/detalhes/{id_ficha}`, mas no **Frontend** (`admin_dashboard_shell.dart`), o item de menu `"Ficha Técnica"` apenas redireciona para `AppRoutes.ficha` (tela de criação de nova ocorrência), não havendo uma tela administrativa de listagem/consulta e visualização de histórico de fichas.

3. **RF04 & FA02 — Auto-salvamento ao interromper preenchimento por emergência crítica**
   - **No PDF:** Ao fechar o app ou bloquear a tela durante emergência, o sistema deve salvar automaticamente o rascunho parcial para retomada posterior sem perda.
   - **No Projeto:** Cada etapa salva no `FichaEmAndamentoProvider` e `DatabaseService` ao clicar em "Continuar", mas não há listener de `WidgetsBindingObserver` (`AppLifecycleState.paused/inactive`) salvando o rascunho automaticamente nem tela/modal de "Retomar atendimento em andamento" ao reabrir o app.

4. **RN10 / RN11 / RN12 — Seleção de Médico e Profissional a partir do Cadastro Real**
   - **No PDF:** A tela inicial da ficha deve listar apenas os profissionais e médicos cadastrados mantidos pelo Administrador.
   - **No Projeto:** `RegistroAtendimentoView` (`registro_atendimento_view.dart`) utiliza uma lista fixa `_medicosDisponiveis` em memória (e campos de texto livre para técnico e condutor) em vez de buscar dinamicamente de `AdminDataService` / `/api/cadastros/medicos`, `/tecnicos` e `/condutores`.

5. **FA01 — Fluxo Alternativo de Falha na Captura de GPS**
   - **No PDF:** Exibir alerta específico `"Sinal de GPS não encontrado"`, pedir tentativa em área aberta ou permitir inserção manual justificada registrando pendência de localização.
   - **No Projeto:** `GpsService` trata falhas retornando erro silencioso/genérico sem registrar flag explícita de pendência de localização na ficha.

6. **RF08 — Filtro por Data e Unidade na listagem de Fichas**
   - **No Projeto:** Os filtros foram conectados ao `/api/reports/dashboard` (métricas), mas `GET /api/fichas/` ainda não expõe filtros por `data_inicio`, `data_fim` e `id_unidade` nem há tela de busca de fichas no Frontend.

7. **RN07 — Imutabilidade de Fichas Finalizadas**
   - **No Projeto:** Não há endpoint `PUT/PATCH` de edição de ficha no Backend (o que ajuda na imutabilidade), porém no Frontend local (`DatabaseService.inserirFicha` com `ConflictAlgorithm.replace`) uma ficha sincronizada não bloqueia explicitamente reedição caso seja carregada novamente.

---

### 3.2 Diferenças de Arquitetura, Segurança e Infraestrutura (Seções 5.4, 6 e RNF)

1. **Criptografia em Repouso no SQLite Local (Seção 5.4 / 6.1 — SQLCipher AES-256)**
   - **No PDF:** Prevê `SQLite (SQLCipher)` com criptografia AES-256 no banco local do dispositivo.
   - **No Projeto:** Utiliza `sqflite` padrão (banco local em texto claro no dispositivo).

2. **Cache e Mensageria com Redis (Seção 5.4 / 9.5)**
   - **No PDF:** Prevê Redis para cache de leitura e enfileiramento de tarefas assíncronas.
   - **No Projeto:** Não há Redis configurado no `Dockerfile` ou `requirements.txt`; o rate limit (`rate_limit.py`) usa memória local (`memory://`), o que não escala entre múltiplos workers/réplicas.

3. **Comunicação HTTPS/TLS 1.2+ (RNF07 / Seção 6.1 & 6.4)**
   - **No PDF:** Comunicação obrigatória via HTTPS com TLS 1.2+ e HSTS.
   - **No Projeto:** `docker/nginx.conf` expõe apenas HTTP na porta `8080` (adequado atrás de Ingress/Proxy reverso municipal com TLS, mas exige terminação SSL em produção).

4. **Esteira de CI/CD Automatizada (RNF09 / Seção 9.5)**
   - **No PDF:** Prevê pipeline de CI/CD com linting (`Black`, `Ruff`, `flutter analyze`), SAST (`Bandit`, `Trivy`) e testes automatizados.
   - **No Projeto:** Não há diretório `.github/workflows/` configurado no repositório.

---

### 3.3 Divergências de Modelo de Dados (Seção 5.2 vs. Implementação)

1. **Campos dos Cadastros Administrativos (`AdminDataService` ↔ `Backend/models/`)**
   - Os formulários do painel administrativo no Frontend coletam `cpf`, `unidade`, `matricula`, `cargo` e `status` para profissionais, e `codigo` e `tipo` para unidades móveis.
   - No Backend (`models/medico.py`, `tecnico.py`, `condutor.py`, `unidade_movel.py`), essas colunas extras ainda não existem (apenas `nome`/`codigo_*` e `placa`/`base_unidade`/`status`), fazendo com que os dados complementares fiquem apenas em memória no Frontend.

2. **Nomenclatura das Tabelas**
   - O diagrama ER do PDF (Figura 22) usa nomes como `FICHAS`, `MEDICOS`, `USUARIO` e colunas camelCase (`nomeUsuario`, `dataFicha`).
   - O Backend implementado padronizou corretamente para `snake_case` (`ficha_atendimento`, `medico`, `usuario`, `avaliacao_clinica`, `utensilios_gastos`, `log_auditoria`, etc.), melhor estruturado e normalizado do que o rascunho inicial do diagrama.

3. **Fluxo de Telas Assistenciais vs. Wireframes (Seção 4.2)**
   - Os wireframes iniciais do PDF (Figuras 15–17) previam ~3 telas simples para a ficha; o projeto evoluiu para um fluxo completo de 7 etapas assistenciais + impressão, separando Dados do Paciente, Avaliação Clínica, Assinatura Digital (com DocuSign) e Folhas de Gastos (Medicamentos e Materiais).

