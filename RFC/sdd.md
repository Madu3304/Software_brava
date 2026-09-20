# Software Brava — Documento de Especificação (Spec-Driven Development)

**Projeto:** Software Brava — Ficha Técnica Digital do SAMU de Joinville
**Curso:** Engenharia de Software
**Orientador:** Diogo Vinícius Winck
**Autor:** Maria Eduarda Nunes de Souza
**Instituição:** Centro Universitário Católica de Santa Catarina
**Versão do documento:** 2.0 (reestruturado em SDD a partir do RFC v1.0, 10/03/2026)

> Este documento reorganiza o RFC original segundo a metodologia **Spec-Driven Development (SDD)**, na qual a especificação (o *quê* e o *porquê*) é o artefato central e vive à frente do código, orientando o plano técnico (o *como*) e a quebra em tarefas executáveis. O fluxo segue quatro camadas: **Constituição → Especificação (Spec) → Plano (Plan) → Tarefas (Tasks)**, com uma matriz de rastreabilidade ligando cada requisito original a uma tarefa concreta.

---

## Sumário

1. [Constituição do Projeto](#1-constituição-do-projeto)
2. [Especificação (Spec)](#2-especificação-spec)
3. [Plano Técnico (Plan)](#3-plano-técnico-plan)
4. [Tarefas (Tasks)](#4-tarefas-tasks)
5. [Matriz de Rastreabilidade](#5-matriz-de-rastreabilidade)
6. [Governança, Marcos e Referências](#6-governança-marcos-e-referências)

---

## 1. Constituição do Projeto

A Constituição define os princípios não negociáveis que toda especificação, plano e tarefa deste projeto deve respeitar. Qualquer conflito entre uma tarefa futura e um destes princípios deve ser resolvido a favor da Constituição.

| # | Princípio | Justificativa |
|---|---|---|
| C1 | **Offline-First é inegociável.** Nenhuma funcionalidade de preenchimento da ficha pode depender de conectividade em tempo real. | A operação ocorre em campo, em áreas com sombra de sinal (RF05, RN06). |
| C2 | **Nenhum dado pode ser perdido.** Toda ficha iniciada deve poder ser retomada e sincronizada com integridade transacional de 100%. | Consequência direta de falha = risco à continuidade do cuidado e à auditoria (RF04, RN06, KPI de Confiabilidade de Sincronização). |
| C3 | **Privacidade por padrão (LGPD by design).** Minimização de dados, criptografia em repouso e em trânsito, e RBAC estrito são requisitos de arquitetura, não *features* opcionais. | Dados de saúde são categoria sensível (Art. 5º, LGPD); a Prefeitura é Controladora e o sistema atua como Operador. |
| C4 | **Simplicidade operacional acima de robustez genérica.** O sistema atende exclusivamente às 4 unidades do SAMU de Joinville — não deve replicar a complexidade de soluções estaduais (ex.: IDS SAMU/SP). | Identificado no benchmark (seção 2.4) como a principal lacuna das soluções existentes. |
| C5 | **Imutabilidade após finalização.** Uma ficha finalizada é um registro legal/clínico e não pode ser alterada. | RN07 — integridade e não-repúdio. |
| C6 | **Validação do servidor é a fonte de verdade.** Nenhuma regra de autorização pode depender apenas do cliente (mobile/web). | Previne bypass de perfil via manipulação de URL (seção 6.3). |

---

## 2. Especificação (Spec)

> A Spec descreve **o que** o sistema deve fazer e **por que**, a partir da perspectiva do usuário e do negócio — deliberadamente livre de detalhes de implementação, que pertencem ao Plano (Seção 3).

### 2.1 Problema e Motivação

**Quem é afetado:** equipes operacionais das 4 unidades móveis do SAMU de Joinville (condutor socorrista + técnico de enfermagem/enfermeiro) e a gestão de saúde pública municipal.

**Problema:** durante o atendimento, a equipe preenche manualmente uma ficha técnica extensa em papel, contendo dados clínicos, histórico, intervenções e horários. Uma via é entregue ao hospital; outra retorna à base do SAMU para digitação posterior. Isso consome tempo assistencial crítico, introduz risco de ilegibilidade e atrasa a disponibilidade de dados epidemiológicos.

**Evidência:** levantamento realizado via duas entrevistas presenciais com representantes da Prefeitura de Joinville (fev./mar. 2026), incluindo análise conjunta da ficha física em uso. O mesmo problema foi identificado como não exclusivo do município (caso do estado de São Paulo, que resolveu de forma paga e não localizada — ver benchmark).

**Objetivo geral:** otimizar o ciclo de registro e arquivamento das fichas de socorro do SAMU de Joinville por meio de um sistema móvel e web escalável, seguro e integrado à base municipal.

**Objetivos específicos:**
- Eliminar o preenchimento manual em papel e a digitação secundária.
- Garantir continuidade do registro em zonas sem conectividade (Offline-First).
- Prover painel gerencial em tempo real para decisão epidemiológica e logística.
- Garantir conformidade estrita com a LGPD para dados sensíveis de saúde.

### 2.2 Análise de Soluções Existentes (Benchmark)

| Critério | IDS SAMU (referência de mercado) |
|---|---|
| Público-alvo | Prefeituras e equipes de socorro móvel em geral |
| Funcionalidade principal | Digitalizar o preenchimento da ficha técnica |
| Limitação | Pago, licenciamento por município, robusto demais e desenhado para a realidade de São Paulo |
| Lacuna não resolvida | Complexidade excedente e custo inviável para a realidade local de Joinville |
| Diferencial do Software Brava | Solução dedicada às 4 unidades de Joinville, acesso simplificado, foco na rotina operacional local |

### 2.3 Personas

| Persona | Papel | Objetivo principal |
|---|---|---|
| **Marina** | Administradora Municipal | Gerenciar semanalmente todas as unidades e acompanhar atendimentos via Dashboard. |
| **Gregório** | Condutor Socorrista (unidade Brava 2) | Conduzir a equipe até a ocorrência e transportar o paciente com segurança. |
| **Ana** | Técnica de Enfermagem (unidade Brava 2) | Prestar primeiros socorros e auxiliar o enfermeiro. |
| **Joaquim** | Enfermeiro (unidade Brava 2) | Prestar primeiros socorros e coordenar o atendimento. |
| **Médico (perfil referenciado)** | Médico de plantão | Referenciado no cadastro para identificação na ficha; **sem** acesso ao app ou ao painel administrativo. |

### 2.4 Cenários de Usuário e Critérios de Aceite

Cada cenário segue o formato **Dado / Quando / Então**, servindo de base direta para testes de aceitação.

#### US-01 — Preenchimento digital da ficha em campo
> Como técnico de enfermagem/enfermeiro, quero preencher a ficha técnica no tablet durante o atendimento, para eliminar o papel e reduzir erros.

- **Dado** que estou autenticado com meu login individual,
  **quando** finalizo a autenticação,
  **então** sou redirecionado diretamente para a tela da Ficha Técnica (sem passar pelo Dashboard). *(RF01, RN10)*
- **Dado** que estou preenchendo a ficha,
  **quando** um campo possui opções padronizadas,
  **então** o sistema apresenta botões de múltipla escolha em vez de campo aberto. *(RF02, RN04)*
- **Dado** que envio a ficha,
  **quando** um campo obrigatório está vazio ou em formato inválido,
  **então** o sistema bloqueia o envio e sinaliza o campo. *(RF03, RN03)*

#### US-02 — Continuidade em emergência crítica (offline-first)
> Como enfermeiro, quero que meu preenchimento seja salvo automaticamente se eu precisar interromper para priorizar o paciente, para não perder informação nem retrabalho.

- **Dado** que estou preenchendo a ficha,
  **quando** fecho o app ou bloqueio a tela abruptamente,
  **então** o sistema salva automaticamente o progresso e permite retomada posterior sem perda de dados. *(RF04, FA02)*
- **Dado** que não há conexão de rede,
  **quando** preencho e envio a ficha,
  **então** os dados são persistidos localmente (SQLite/SQLCipher) e sincronizados automaticamente ao reconectar. *(RF05, RN06, C1, C2)*

#### US-03 — Falha de GPS
> Como condutor/enfermeiro, quero registrar a localização do atendimento mesmo quando o GPS falha, para não travar o atendimento por um problema técnico.

- **Dado** que informo o CEP do local,
  **quando** o dispositivo não obtém coordenadas,
  **então** o sistema exibe "Sinal de GPS não encontrado", permite nova tentativa em área aberta ou inserção manual justificada, registrando a pendência. *(RF09, FA01)*

#### US-04 — Conflito de sincronização
> Como Administrador, quero que o sistema nunca sobrescreva dados automaticamente em caso de conflito, para preservar a integridade do histórico clínico.

- **Dado** que uma ficha local diverge da versão já enviada ao banco da Prefeitura,
  **quando** a conexão é restabelecida,
  **então** o sistema bloqueia a sobrescrita automática e mantém a versão mais completa disponível para validação manual. *(FA03, RN07, C5)*

#### US-05 — Identificação do responsável e do médico de plantão
> Como Administrador, quero que toda ficha identifique de forma inequívoca quem a preencheu e qual médico estava de plantão, para garantir rastreabilidade e não-repúdio.

- **Dado** que abro uma nova ficha,
  **quando** a tela inicial é carregada,
  **então** um campo obrigatório lista apenas profissionais previamente cadastrados para seleção do responsável pelo preenchimento. *(RN10)*
- **Dado** que estou finalizando a saída da unidade,
  **quando** preencho a ficha,
  **então** o sistema exige a seleção do médico de plantão a partir do cadastro mantido pelo Administrador. *(RN11, RN12)*

#### US-06 — Gestão de cadastros pelo Administrador
> Como Marina (Administradora), quero cadastrar médicos, unidades, técnicos, condutores e enfermeiros, para manter o corpo clínico e a frota atualizados.

- **Dado** que estou autenticada como Administradora,
  **quando** acesso o menu lateral,
  **então** posso cadastrar novos médicos, unidades básicas móveis, técnicos de enfermagem, condutores socorristas e enfermeiros. *(RF10)*

#### US-07 — Monitoramento de paradas de unidade
> Como Marina, quero saber quando e por que uma unidade está parada, para agir rapidamente sobre indisponibilidades.

- **Dado** que uma unidade está indisponível no início de uma ficha,
  **quando** o profissional indica essa condição,
  **então** o sistema registra o motivo da parada e o exibe no dashboard de monitoramento. *(RF11, RF12)*

#### US-08 — Dashboard gerencial
> Como Marina, quero visualizar indicadores operacionais consolidados, para apoiar decisões de saúde pública.

- **Dado** que estou no Dashboard,
  **quando** aplico filtros cronológicos (dia/mês/ano),
  **então** visualizo volume de atendimentos por unidade, faixa etária dos pacientes, locais com maior ocorrência e tempo médio de resposta. *(RF13, RF14, RF15, RF16)*

#### US-09 — Consulta e exportação de registros
> Como Administrador, quero buscar atendimentos por data/unidade e gerar relatórios em PDF, para auditoria e envio ao hospital.

- **Dado** que preciso localizar um atendimento,
  **quando** busco por data ou unidade,
  **então** o sistema retorna os registros correspondentes. *(RF07, RF08, RN08, RN09)*
- **Dado** que uma ficha foi finalizada,
  **quando** solicito a exportação,
  **então** o sistema gera um arquivo PDF pronto para entrega ao hospital de destino. *(RNF08)*

#### US-10 — Controle de acesso por perfil
> Como qualquer usuário, quero acessar apenas as telas do meu perfil, para que dados sensíveis fiquem protegidos.

- **Dado** que estou autenticado como Enfermeiro/Técnico,
  **quando** tento acessar a URL do Dashboard diretamente,
  **então** o servidor nega o acesso, independentemente de manipulação da URL no navegador. *(RN01, C6, seção 6.3)*

### 2.5 Requisitos Funcionais (RF) — visão consolidada

| Código | Descrição | User Story |
|---|---|---|
| RF01 | Registro digital de atendimentos pelas unidades do SAMU. | US-01 |
| RF02 | Campos de múltipla escolha para reduzir erros. | US-01 |
| RF03 | Validação automática de dados (obrigatoriedade, formato). | US-01 |
| RF04 | Preservação de preenchimento parcial em caso de interrupção. | US-02 |
| RF05 | Funcionamento offline. | US-02 |
| RF06 | Integração dos dados com o banco da Prefeitura. | US-02 |
| RF07 | Geração de relatórios de atendimentos. | US-09 |
| RF08 | Busca de registros por data ou unidade. | US-09 |
| RF09 | Registro de coordenadas geográficas do atendimento. | US-03 |
| RF10 | Cadastro de médicos, unidades, técnicos, condutores e enfermeiros pelo Administrador. | US-06 |
| RF11 | Registro de unidade parada e motivo, no início da ficha. | US-07 |
| RF12 | Registro das unidades no dashboard de monitoramento de paradas. | US-07 |
| RF13 | Métricas de número de atendimentos no dashboard. | US-08 |
| RF14 | Métricas de faixa etária dos pacientes no dashboard. | US-08 |
| RF15 | Métricas de locais com maior ocorrência no dashboard. | US-08 |
| RF16 | Métricas de tempo médio de resposta das unidades no dashboard. | US-08 |

### 2.6 Requisitos Não Funcionais (RNF)

| Código | Descrição | Princípio associado |
|---|---|---|
| RNF01 | Carregamento das páginas principais em até 5s em condições normais. | — |
| RNF02 | Autenticação obrigatória para funcionalidades restritas. | C3, C6 |
| RNF03 | Minimização e proteção de dados conforme LGPD. | C3 |
| RNF04 | Código-fonte modular. | — |
| RNF05 | Logs de execução, erro e falha de integração, com rastreabilidade. | C3 |
| RNF06 | Compatibilidade com os principais navegadores atuais (interface web). | — |
| RNF07 | Comunicação segura via HTTPS. | C3 |
| RNF08 | Exportação da ficha preenchida em PDF. | US-09 |
| RNF09 | Pipeline automatizada de CI/CD com testes unitários e de integração. | — |

### 2.7 Regras de Negócio (RN)

| Código | Descrição |
|---|---|
| RN01 | Perfis distintos: Administrador e Corpo Assistencial (Enfermeiro/Técnico). |
| RN02 | Toda ocorrência exige ficha técnica preenchida antes do encerramento. |
| RN03 | Campos essenciais são obrigatórios para finalização da ficha. |
| RN04 | Preenchimento via opções pré-definidas sempre que possível. |
| RN05 | Geolocalização (GPS) registrada automaticamente. |
| RN06 | Dados offline armazenados localmente e sincronizados ao reconectar. |
| RN07 | Ficha finalizada não pode ser alterada (imutabilidade). |
| RN08 | Consulta de histórico de atendimentos para análise/auditoria. |
| RN09 | Relatórios gerados a partir dos atendimentos registrados. |
| RN10 | Campo obrigatório de seleção do profissional responsável, na tela inicial da ficha. |
| RN11 | Registro obrigatório do médico de plantão na saída da unidade. |
| RN12 | Reforço: toda ficha deve identificar o médico responsável pelo plantão. |
| RN13 | Autenticação: (a) Administrador com login/senha individual; (b) Enfermeiro/Condutor/Técnico com login padrão por unidade (4 unidades bravas) + senha. |

> **Nota de especificação (débito técnico já identificado):** a RN13(b) — login padrão compartilhado por viatura — conflita com o princípio C3 (rastreabilidade individual) e foi formalmente marcada como *melhoria futura* pela própria autora (ver seção 6, item "Login"), substituindo-a por autenticação individual obrigatória. Isso é tratado na Seção 4 como **débito técnico rastreado**, não como contradição silenciosa.

### 2.8 Fora do Escopo

- Diagnósticos, recomendações médicas ou análise clínica automatizada.
- Gerenciamento completo de prontuários hospitalares ou integração total com sistemas internos dos hospitais (limita-se à impressão da ficha para entrega).
- Gestão operacional do SAMU (despacho, rotas, frota, alocação de equipes).
- Garantia de conectividade em campo (o sistema só garante o armazenamento local e sincronização posterior).
- Substituição de processos legais que exijam documentação física.
- BI avançado ou indicadores estratégicos complexos (apenas relatórios operacionais básicos).
- Integração com dispositivos médicos/sensores externos.

### 2.9 Métricas de Sucesso (KPIs) — Definition of Done do produto

| KPI | Meta | Como medir |
|---|---|---|
| Taxa de erros no preenchimento | Redução significativa | Comparação de inconsistências pré/pós-implantação de validação em tempo real. |
| Tempo de ciclo da documentação | Redução ≥ 60% | Tempo médio de preenchimento (papel vs. digital). |
| Disponibilidade da API central | ≥ 99,5% *uptime* | Monitoramento de infraestrutura (SLA). |
| Confiabilidade de sincronização offline | 100% de integridade transacional | Auditoria de pacotes offline vs. registros persistidos. |

---

## 3. Plano Técnico (Plan)

> O Plano traduz a Spec em decisões de arquitetura e tecnologia. Toda decisão aqui deve ser justificável por um item da Seção 2 ou da Constituição (Seção 1).

### 3.1 Arquitetura — Modelo C4

| Nível | Conteúdo | Rastreabilidade |
|---|---|---|
| **N1 — Contexto** | O Sistema Digital do SAMU como caixa-preta, integrando Equipe Assistencial, Administrador, Banco de Dados da Prefeitura e Hospital de Destino. | C1–C6 |
| **N2 — Containers** | App Web/Mobile (Flutter/Flutter Web) + API Back-end (regras de negócio/integrações) + Banco de Dados, com integração ao banco da Prefeitura e ao Hospital de Destino. | RF01, RF06 |
| **N3 — Componentes** | Módulos de autenticação, gerenciamento de usuários, registro de atendimentos, controle de fichas, geração de indicadores, integração externa. | RF10, RF13–RF16, RN01 |
| **N4 — Código** | Classes, métodos e entidades que implementam os módulos acima, garantindo modularidade e comunicação entre camadas. | RNF04 |

### 3.2 Stack Tecnológica (decisão → requisito que a motiva)

| Camada | Tecnologia | Requisito(s) que justificam |
|---|---|---|
| Front-end Mobile | Flutter (Dart) + SQLite (SQLCipher) | RF05, RF04, C1, C2, criptografia em repouso (6.1) |
| Front-end Web | Flutter Web (Dashboard corporativo responsivo) | RF13–RF16, RNF06 |
| Back-end API | Python 3.12+, FastAPI, Pydantic | RF03, RNF01, RNF04 |
| ORM | SQLAlchemy 2.0 (+ `asyncpg`) | RNF04, proteção contra SQL Injection (6.4) |
| Banco central | PostgreSQL 16+ com replicação e índices | RF06, RNF01, RNF03 |
| Cache/Mensageria | Redis (leitura + filas assíncronas) | RNF01, escalabilidade (melhorias futuras) |

### 3.3 Modelo de Dados

Arquitetura baseada em PostgreSQL, organizada em **sete tabelas principais** e **uma view temporária** para consultas específicas (detalhamento no diagrama de banco do repositório do projeto).

### 3.4 Componentes Principais

| Componente | Responsabilidade | Requisito(s) |
|---|---|---|
| API (Backend) | Ponte segura app ↔ servidor; recebe fichas, valida regras de negócio, atende o Dashboard. | RF01, RF03, RF06 |
| Sistema de Autenticação (RBAC) | Redireciona por perfil; protege dados sensíveis conforme LGPD. | RN01, RNF02, RNF03, C6 |
| Módulo de Processamento e Sincronização | Lógica Offline-First; envia dados ao reconectar (Wi-Fi/4G). | RF05, RF06, RN06, C1, C2 |
| Camada de Persistência | SQLite (cliente) + PostgreSQL (servidor). | RF05, RF06 |
| Módulo de Coleta e Validação (Ficha Técnica Digital) | Interface tablet; múltipla escolha, validação, GPS. | RF01–RF03, RF09 |
| Painel de Gestão (Dashboard) | Métricas + cadastro do corpo clínico/frota. | RF10, RF13–RF16 |

### 3.5 Segurança e Privacidade (Plano técnico para C3)

| Controle | Implementação | Requisito |
|---|---|---|
| Criptografia em repouso | AES-256 local + colunas sensíveis encriptadas no PostgreSQL (KMS). | RNF03 |
| Criptografia em trânsito | HTTPS/TLS 1.2+ com HSTS. | RNF07 |
| Senhas | *Hash* unidirecional com salt dinâmico (bcrypt/Argon2). | RNF02 |
| RBAC | Administrador (gestão + leitura de fichas, sem edição pós-finalização) vs. Enfermeiro/Técnico (apenas a própria ficha, sem Dashboard). | RN01, C5, C6 |
| Validação de rota | 100% no backend — nunca confiar apenas no roteamento client-side. | C6 |
| Revalidação de token na sincronização offline | Token revalidado antes de aceitar dados enviados em modo offline. | RN06, C2 |
| Proteção contra SQL Injection | ORM SQLAlchemy + validação de entrada em todos os *endpoints*. | RNF04 |
| Logs e rastreabilidade | Nome do preenchedor + data/hora/ação + ID da unidade/ficha; **nunca** dados clínicos sensíveis; acesso restrito ao Administrador. | RNF05, C3 |
| Direitos dos titulares | Pacientes/representantes e profissionais podem solicitar acesso, correção e (para profissionais) inativação, junto à Prefeitura (Controladora) — Art. 18 LGPD. | C3 |
| Governança | Prefeitura = Controladora; sistema = Operador; supervisão do DPO municipal. | C3 |

### 3.6 Infraestrutura, Escalabilidade e DevOps (visão de plano de evolução)

- **Containerização:** Docker, imagens *distroless*/*alpine*.
- **Balanceamento/Proxy reverso:** NGINX ou Traefik (encerramento SSL/TLS, *ingress* único).
- **CI/CD:** *lint*/formatação (Black, Ruff, `flutter analyze`) → SAST (Bandit, Trivy) → testes automatizados (`pytest` + *Testcontainers*) → build/publicação versionada semanticamente. *(RNF09)*
- **Observabilidade:** métricas Prometheus, painéis Grafana, logs estruturados (JSON) + *tracing* distribuído (OpenTelemetry).

---

## 4. Tarefas (Tasks)

> Cada tarefa nasce de uma célula da Spec (Seção 2) ou do Plano (Seção 3) e é agrupada pelos marcos já pactuados com a Prefeitura/orientação. Marcadas com **[DÉBITO]** as tarefas que resolvem itens identificados como melhoria futura na Seção 6.

### T1 — Especificação e Validação com Usuário Final *(→ M1, M2)*
- [ ] T1.1 Consolidar entrevistas e evidências de campo na Spec (concluído nesta versão — Seção 2.1–2.2).
- [ ] T1.2 Validar personas e casos de uso com a Administradora (Marina) e representante da Prefeitura.
- [ ] T1.3 Congelar protótipos de alta fidelidade (Figma/v0) referenciados no Apêndice.
- [ ] T1.4 Revisar e assinar a matriz RF/RNF/RN (Seção 2.5–2.7) como *baseline* contratual do RFC.

### T2 — Front-end Mobile (perfil Enfermeiro/Técnico/Condutor) *(→ M4)*
- [ ] T2.1 Tela de login individual (US-01).
- [ ] T2.2 Tela 1 da Ficha Técnica: identificação do profissional responsável + médico de plantão (US-05, RN10–RN12).
- [ ] T2.3 Telas 2 e 3 da Ficha Técnica: campos de múltipla escolha e validação em tempo real (US-01, RF02, RF03).
- [ ] T2.4 Persistência local SQLite/SQLCipher + salvamento automático em interrupção (US-02, RF04).
- [ ] T2.5 Captura de GPS + fluxo alternativo de falha de sinal (US-03, RF09, FA01).
- [ ] T2.6 Fila de sincronização Offline-First + resolução de conflito sem sobrescrita automática (US-02, US-04, RF05, RF06, FA03).
- [ ] T2.7 Campo de "unidade parada" + motivo, no início da ficha (US-07, RF11).

### T3 — Front-end Web (perfil Administrador) *(→ M5)*
- [ ] T3.1 Tela de login administrativo + redirecionamento automático ao Dashboard.
- [ ] T3.2 Dashboard — métricas de volume, faixa etária, locais e tempo médio de resposta, com filtros cronológicos (US-08, RF13–RF16).
- [ ] T3.3 Dashboard de monitoramento de paradas por unidade (US-07, RF12).
- [ ] T3.4 Módulos de cadastro: médicos, unidades móveis, técnicos, condutores, enfermeiros (US-06, RF10).
- [ ] T3.5 Consulta e busca de fichas por data/unidade + exportação em PDF (US-09, RF07, RF08, RNF08).

### T4 — Back-end e Infraestrutura de Dados *(→ M6)*
- [ ] T4.1 Modelagem das 7 tabelas + view de consulta no PostgreSQL (Seção 3.3).
- [ ] T4.2 API RESTful (FastAPI/Pydantic) para CRUD de fichas, cadastros e métricas.
- [ ] T4.3 Camada ORM SQLAlchemy 2.0 assíncrona (`asyncpg`) com proteção contra SQL Injection.
- [ ] T4.4 Pipeline de sincronização offline→online com revalidação de token (RN06, seção 6.4).
- [ ] T4.5 Módulo de autenticação RBAC com validação 100% *server-side* (C6, seção 6.3).
- [ ] T4.6 Módulo de logs e auditoria (metadados apenas, sem dados clínicos) — RNF05, 6.5.
- [ ] T4.7 Cache/mensageria com Redis para leitura e filas assíncronas.

### T5 — Segurança e Conformidade LGPD *(transversal a M4–M6)*
- [ ] T5.1 Criptografia AES-256 em repouso (local e PostgreSQL) via KMS.
- [ ] T5.2 HTTPS/TLS 1.2+ com HSTS em toda comunicação cliente-servidor.
- [ ] T5.3 *Hash* de senha com salt dinâmico (bcrypt/Argon2).
- [ ] T5.4 Processo documentado de atendimento aos direitos dos titulares (Art. 18 LGPD) junto à Prefeitura.
- [ ] T5.5 **[DÉBITO]** Substituir login padrão compartilhado por unidade (RN13-b) por autenticação individual obrigatória para todos os perfis, cumprindo não-repúdio.

### T6 — Qualidade, DevOps e Observabilidade *(→ M6–M8)*
- [ ] T6.1 Pipeline CI/CD: lint (Black/Ruff/`flutter analyze`) → SAST (Bandit/Trivy) → testes (`pytest`/Testcontainers) → build versionado. *(RNF09)*
- [ ] T6.2 Containerização dos módulos backend (Docker, imagens distroless/alpine).
- [ ] T6.3 Ingress único com NGINX/Traefik e encerramento SSL/TLS.
- [ ] T6.4 Observabilidade: métricas Prometheus, dashboards Grafana, logs JSON + OpenTelemetry.
- [ ] T6.5 Testes de aceitação automatizados para cada critério "Dado/Quando/Então" da Seção 2.4 (US-01 a US-10).

### T7 — Integração Final e Entrega *(→ M7, M8)*
- [ ] T7.1 Integração ponta a ponta mobile ↔ API ↔ Dashboard ↔ banco da Prefeitura.
- [ ] T7.2 Testes de carga para validar RNF01 (< 5s) e o KPI de *uptime* 99,5%.
- [ ] T7.3 Homologação com feedback de usuários finais (nova rodada, seguindo o modelo da reunião de 08/05/2026).
- [ ] T7.4 Publicação do repositório em acesso público (front + backend).
- [ ] T7.5 **[DÉBITO]** Avaliar e priorizar melhorias futuras não incluídas nesta entrega (Seção 6.2).

---

## 5. Matriz de Rastreabilidade

Liga cada requisito original do RFC (RF/RNF/RN) à User Story correspondente e à(s) tarefa(s) que a implementam — garante que nenhuma linha da Spec fique "órfã" no Plano/Tasks.

| Requisito | User Story | Tarefa(s) |
|---|---|---|
| RF01, RF02, RF03 | US-01 | T2.1–T2.3 |
| RF04 | US-02 | T2.4 |
| RF05, RF06 | US-02 | T2.6, T4.4 |
| RF07, RF08 | US-09 | T3.5 |
| RF09 | US-03 | T2.5 |
| RF10 | US-06 | T3.4 |
| RF11, RF12 | US-07 | T2.7, T3.3 |
| RF13–RF16 | US-08 | T3.2 |
| RNF01 | — | T7.2 |
| RNF02 | US-10 | T4.5 |
| RNF03 | — | T5.1, T5.2 |
| RNF04 | — | T4.3 |
| RNF05 | — | T4.6 |
| RNF06 | — | T3.1–T3.4 (Flutter Web) |
| RNF07 | — | T5.2 |
| RNF08 | US-09 | T3.5 |
| RNF09 | — | T6.1 |
| RN01–RN09 | US-01, US-04, US-09, US-10 | T2.6, T4.5, T3.5 |
| RN10–RN12 | US-05 | T2.2 |
| RN13 | US-10 | T4.5, T5.5 **[DÉBITO]** |

---

## 6. Governança, Marcos e Referências

### 6.1 Marcos do Projeto

| Marco | Descrição | Prazo |
|---|---|---|
| M1 | Primeira versão do RFC e validação com o Administrador; feedback coletado. | 08/05/2026 |
| M2 | Conclusão do RFC: requisitos, arquitetura, protótipos de alta fidelidade e cronograma. | 11/06/2026 |
| M3 | Coleta e ajustes de observações dos monitores. | 22/06/2026 |
| M4 | Front-end mobile — telas do usuário comum. | 19/06/2026 |
| M5 | Front-end web — telas do Administrador. | 17/07/2026 |
| M6 | Back-end: API RESTful, sincronização offline e persistência (SQLAlchemy/PostgreSQL). | 21/08/2026 |
| M7 | Primeira visão integrada. | 18/09/2026 |
| M8 | Integração final, testes e entrega completa. | 18/10/2026 |

### 6.2 Melhorias Futuras (débitos técnicos declarados)

- Envio automático da ficha em PDF para o e-mail do hospital de destino.
- Assinatura digital de aceite no tablet.
- Fragmentação da ficha em 6 sub-fichas específicas por etapa do atendimento.
- **Autenticação individual obrigatória** substituindo o login genérico compartilhado por viatura (RN13-b) — item de conformidade LGPD (não-repúdio e auditoria).
- Camada de cache distribuído (Redis) para reduzir I/O sobre o PostgreSQL.

### 6.3 Papéis de Governança

A **Prefeitura Municipal de Joinville** atua como Controladora dos Dados; o sistema atua como Operador, sob supervisão do Encarregado de Dados (DPO) municipal. A infraestrutura e os servidores são de responsabilidade da Prefeitura.

### 6.4 Referências

**Legislação**
- BRASIL. Lei nº 13.709, de 14 de agosto de 2018 (LGPD). Disponível em: https://www.planalto.gov.br. Acesso em: 10 mar. 2026.
- BRASIL. Ministério da Saúde. Portaria GM/MS nº 2.048, de 5 de novembro de 2002. Disponível em: https://bvsms.saude.gov.br. Acesso em: 10 mar. 2026.

**Pesquisa de campo:** entrevistas e apresentação institucional com representantes da Prefeitura Municipal de Joinville (fev. 2026).

**Ferramentas e tecnologias:** Flutter (https://flutter.dev), FastAPI (https://fastapi.tiangolo.com), PostgreSQL (https://www.postgresql.org), SQLite (https://www.sqlite.org), SQLAlchemy (https://www.sqlalchemy.org).

**Benchmark:** IDS SAMU — https://play.google.com/store/apps/details?id=br.inf.ids.samuapp

**Protótipos e diagramas:**
- Figma (protótipo de interface): https://www.figma.com/make/VmeE1TRLdNX4DjaYeRGYNl/Mobile-form-app
- v0.app (dashboard): https://v0.app/chat/dashboard-de-unidades-d3OGiWr3ehe
- draw.io (casos de uso e navegação): https://drive.google.com/file/d/1i06F5xgMuuqQa0i_XAX6pAFnFoFOrogO/view
- Repositório (front + C4): https://github.com/Madu3304/Software_brava.git
- Repositório (backend): https://github.com/Madu3304/Software_brava_backend.git