# Script Completo de Criação Automática do Banco `brava` no PostgreSQL (DBeaver)

Este documento reúne toda a estrutura de banco de dados extraída do **Backend (`Backend/models/`)** e compatível com os payloads e fluxos do **Frontend (`Frontend/lib/models/`)**, pronta para ser executada no **DBeaver** conectado ao PostgreSQL.

> **Atenção no DBeaver (PostgreSQL):**
> 1. O comando `CREATE DATABASE brava` deve ser executado **sozinho** (conectado ao banco padrão `postgres`).
> 2. Depois, conecte-se (ou altere o banco ativo na barra superior do DBeaver) para o banco **`brava`** e execute o **Script 2 (DDL + Índices + Carga Inicial)** de uma única vez (`Alt + X` / *Execute SQL Script*).

---

## Passo 1 — Criar o Banco de Dados `brava`

Execute conectado ao servidor PostgreSQL (banco `postgres`):

```sql
CREATE DATABASE brava
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TEMPLATE = template0;
```

*(Caso o seu PostgreSQL no Windows não possua o locale `pt_BR.UTF-8`, utilize simplesmente `CREATE DATABASE brava WITH ENCODING = 'UTF8';`.)*

---

## Passo 2 — Criar Tabelas, Chaves, Índices e Carga Inicial (`brava`)

Após selecionar o banco **`brava`** no DBeaver, execute todo o script abaixo:

```sql
-- ============================================================================
-- SOFTWARE BRAVA (SAMU 192 JOINVILLE) — DDL POSTGRESQL COMPLETO
-- Compatível 100% com SQLAlchemy (Backend/models/) e Frontend Flutter
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. USUÁRIOS DO SISTEMA (RBAC & Autenticação)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(150) UNIQUE,
    login VARCHAR(100) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil VARCHAR(50) NOT NULL, -- 'ADMINISTRADOR', 'ENFERMEIRO', 'TECNICO', 'CONDUTOR'
    registro_profissional VARCHAR(50),
    ativo BOOLEAN DEFAULT TRUE,
    trocar_senha BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 2. BASES OPERACIONAIS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS base (
    id_base SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    endereco VARCHAR(255),
    bairro VARCHAR(100),
    telefone VARCHAR(30),
    ativo BOOLEAN DEFAULT TRUE,
    placa VARCHAR(10),
    base_unidade VARCHAR(50),
    status VARCHAR(30),
    motivo_parada TEXT,
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 3. HOSPITAIS / UPAS DE DESTINO
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hospital_destino (
    id_hospital SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(255)
);

-- ----------------------------------------------------------------------------
-- 4. UNIDADES MÓVEIS (FROTA / VIATURAS)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS unidade_movel (
    id_unidade SERIAL PRIMARY KEY,
    codigo VARCHAR(30),
    placa VARCHAR(10),
    tipo VARCHAR(80),
    base_unidade VARCHAR(50) DEFAULT 'DISPONIVEL',
    status VARCHAR(30) DEFAULT 'DISPONIVEL', -- 'DISPONIVEL', 'EM_ATENDIMENTO', 'PARADA', 'MANUTENCAO'
    motivo_parada TEXT,
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 5. CORPO CLÍNICO E OPERACIONAL (Médicos, Técnicos e Condutores)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS medico (
    id_medico SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    codigo_medico INTEGER,
    cpf VARCHAR(20),
    registro_conselho VARCHAR(50),
    unidade VARCHAR(100),
    matricula VARCHAR(50),
    cargo VARCHAR(100),
    status VARCHAR(30) DEFAULT 'Disponível',
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tecnico (
    id_tecnico SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    codigo_tecnico INTEGER,
    cpf VARCHAR(20),
    registro_conselho VARCHAR(50),
    unidade VARCHAR(100),
    matricula VARCHAR(50),
    cargo VARCHAR(100),
    status VARCHAR(30) DEFAULT 'Disponível',
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS condutor (
    id_condutor SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    codigo_condutor INTEGER,
    cpf VARCHAR(20),
    registro_conselho VARCHAR(50),
    unidade VARCHAR(100),
    matricula VARCHAR(50),
    cargo VARCHAR(100),
    status VARCHAR(30) DEFAULT 'Disponível',
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 6. PACIENTES (Com pseudonimização LGPD do CPF em `documento`)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS paciente (
    id_paciente SERIAL PRIMARY KEY,
    nome VARCHAR(200),
    idade INTEGER,
    sexo VARCHAR(1), -- 'M', 'F', 'O'
    documento VARCHAR(64), -- Hash HMAC-SHA256 hex (64 chars)
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    data_nascimento TIMESTAMPTZ,
    acompanhante VARCHAR(200),
    grau_parentesco VARCHAR(50),
    telefone_acompanhante VARCHAR(20),
    gravidade_previa VARCHAR(20),
    historico_clinico VARCHAR(255),
    alergias VARCHAR(255),
    "medicamentoUso_paciente" VARCHAR(255),
    observacao_paciente VARCHAR(255)
);

-- ----------------------------------------------------------------------------
-- 7. FICHAS DE ATENDIMENTO APH
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ficha_atendimento (
    id_ficha SERIAL PRIMARY KEY,
    uuid_offline VARCHAR(64) UNIQUE,
    id_unidade INTEGER NOT NULL REFERENCES unidade_movel(id_unidade),
    id_responsavel INTEGER NOT NULL REFERENCES usuario(id_usuario),
    id_condutor INTEGER REFERENCES condutor(id_condutor),
    id_paciente INTEGER REFERENCES paciente(id_paciente),
    id_tecnico INTEGER REFERENCES tecnico(id_tecnico),
    id_medico INTEGER REFERENCES medico(id_medico),
    id_base INTEGER REFERENCES base(id_base),
    id_hospital INTEGER REFERENCES hospital_destino(id_hospital),

    -- Localização / GPS
    cep VARCHAR(10),
    logradouro VARCHAR(255),
    bairro VARCHAR(100),
    numero VARCHAR(100),
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    gps_endereco_destino BOOLEAN DEFAULT FALSE,

    -- Horários Operacionais
    hora_chamado TIMESTAMPTZ,
    hora_saida_base TIMESTAMPTZ,
    hora_chegada_local TIMESTAMPTZ,
    hora_saida_local TIMESTAMPTZ,
    hora_chegada_hospital TIMESTAMPTZ,
    hora_conclusao TIMESTAMPTZ,

    -- Status, Parada e Integração Prefeitura
    codigo_local VARCHAR(30),
    unidade_parada BOOLEAN DEFAULT FALSE,
    motivo_unidade_parada TEXT,
    observacoes_gerais TEXT,
    criado_em TIMESTAMPTZ DEFAULT NOW(),

    status_envio_prefeitura VARCHAR(20) NOT NULL DEFAULT 'PENDENTE', -- 'PENDENTE', 'ENVIADO', 'ERRO'
    protocolo_prefeitura VARCHAR(64),
    tentativas_envio INTEGER NOT NULL DEFAULT 0,
    ultima_tentativa_envio TIMESTAMPTZ,
    erro_envio TEXT,
    data_atendimento TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_ficha_atendimento_status_envio
    ON ficha_atendimento(status_envio_prefeitura);

-- ----------------------------------------------------------------------------
-- 8. AVALIAÇÃO CLÍNICA (Sinais Vitais, Glasgow, Cincinnati e Conduta)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS avaliacao_clinica (
    id_avaliacao SERIAL PRIMARY KEY,
    id_ficha INTEGER REFERENCES ficha_atendimento(id_ficha) ON DELETE CASCADE,
    id_paciente INTEGER REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    pressao_arterial VARCHAR(20),
    frequencia_cardiaca INTEGER,
    frequencia_respiratoria INTEGER,
    saturacao_o2 INTEGER,
    glicemia INTEGER,
    temperatura NUMERIC(4, 1),
    escala_glasgow INTEGER,
    abertura_ocular INTEGER,
    resposta_verbal INTEGER,
    resposta_motora INTEGER,
    hemoglicoteste INTEGER,
    hora_ictus TIMESTAMPTZ,
    nome_testemunha VARCHAR(200),
    usa_anticoagulante BOOLEAN,
    assimetria_facial BOOLEAN,
    queda_braco BOOLEAN,
    fala BOOLEAN,
    avc_suspeito BOOLEAN,
    material_retido BOOLEAN,
    "anotacao_CondutaEnfermeiro" TEXT,
    procedimentos_realizados TEXT,
    medicacoes_administradas TEXT,
    conduta TEXT
);

-- ----------------------------------------------------------------------------
-- 9. FOLHA DE GASTOS / UTENSÍLIOS E REPOSIÇÃO
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS utensilios (
    id_utensilios SERIAL PRIMARY KEY,
    id_ficha INTEGER NOT NULL REFERENCES ficha_atendimento(id_ficha) ON DELETE CASCADE,
    id_avaliacao INTEGER REFERENCES avaliacao_clinica(id_avaliacao) ON DELETE SET NULL,
    medicamentos_ampolas BOOLEAN DEFAULT FALSE,
    medicamentos_controlados BOOLEAN DEFAULT FALSE,
    medicamentos_comprimidos BOOLEAN DEFAULT FALSE,
    "medicamentos_frascoGotas" BOOLEAN DEFAULT FALSE,
    anestesico BOOLEAN DEFAULT FALSE,
    material_infusao BOOLEAN DEFAULT FALSE,
    material_sondagem BOOLEAN DEFAULT FALSE,
    material_trauma BOOLEAN DEFAULT FALSE,
    materiais_diversos BOOLEAN DEFAULT FALSE,
    observacoes_reposicao TEXT,
    reposto BOOLEAN DEFAULT FALSE,
    data_reposicao TIMESTAMPTZ,
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_utensilios_id_ficha ON utensilios(id_ficha);
CREATE INDEX IF NOT EXISTS ix_utensilios_id_avaliacao ON utensilios(id_avaliacao);

-- ----------------------------------------------------------------------------
-- 10. LOGS DE AUDITORIA (LGPD — Somente Metadados)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS log_auditoria (
    id_log SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES usuario(id_usuario),
    acao VARCHAR(100) NOT NULL,
    detalhes_metadados VARCHAR(255),
    ip_origem VARCHAR(45),
    data_hora TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 11. CARGA INICIAL (DADOS DE OPERAÇÃO DO SAMU JOINVILLE)
-- ----------------------------------------------------------------------------
INSERT INTO base (nome, endereco, bairro, telefone, ativo)
SELECT 'Base Central SAMU', 'Rua Coronel Procópio Gomes, 1500', 'Bucarein', '(47) 3481-0192', TRUE
WHERE NOT EXISTS (SELECT 1 FROM base WHERE nome = 'Base Central SAMU');

INSERT INTO hospital_destino (nome, endereco)
SELECT 'Hospital Municipal São José', 'Av. Getúlio Vargas, 238 - Anita Garibaldi'
WHERE NOT EXISTS (SELECT 1 FROM hospital_destino WHERE nome = 'Hospital Municipal São José');

INSERT INTO hospital_destino (nome, endereco)
SELECT 'Hospital Regional Hans Dieter Schmidt', 'Rua Xavier Arp, s/n - Boa Vista'
WHERE NOT EXISTS (SELECT 1 FROM hospital_destino WHERE nome = 'Hospital Regional Hans Dieter Schmidt');

INSERT INTO unidade_movel (codigo, placa, tipo, base_unidade, status)
SELECT 'USB-01', 'BRA-0101', 'USB (Suporte Básico)', 'Brava 1', 'DISPONIVEL'
WHERE NOT EXISTS (SELECT 1 FROM unidade_movel WHERE placa = 'BRA-0101');

INSERT INTO unidade_movel (codigo, placa, tipo, base_unidade, status)
SELECT 'USB-02', 'BRA-0202', 'USB (Suporte Básico)', 'Brava 2', 'DISPONIVEL'
WHERE NOT EXISTS (SELECT 1 FROM unidade_movel WHERE placa = 'BRA-0202');

INSERT INTO unidade_movel (codigo, placa, tipo, base_unidade, status)
SELECT 'USB-03', 'BRA-0303', 'USB (Suporte Básico)', 'Brava 3', 'DISPONIVEL'
WHERE NOT EXISTS (SELECT 1 FROM unidade_movel WHERE placa = 'BRA-0303');

INSERT INTO unidade_movel (codigo, placa, tipo, base_unidade, status)
SELECT 'USB-04', 'BRA-0404', 'USB (Suporte Básico)', 'Brava 4', 'DISPONIVEL'
WHERE NOT EXISTS (SELECT 1 FROM unidade_movel WHERE placa = 'BRA-0404');

COMMIT;
```

---

## Passo 3 — Conectar o Backend ao PostgreSQL `brava`

No arquivo `.env` do `Backend/` (ou nas variáveis do Docker), aponte `DATABASE_URL` para o PostgreSQL:

```env
DATABASE_URL=postgresql://postgres:SUA_SENHA@localhost:5432/brava
APP_ENV=development
JWT_SECRET_KEY=sua_chave_secreta_jwt_aqui
CPF_HMAC_KEY=sua_chave_hmac_aqui
```

Ao subir o Backend (`uvicorn main:app`), os usuários padrão (`admin`, `enfermeiro`, `tecnico`, `condutor`) são populados automaticamente pelo `seed.py` com hash `bcrypt` (custo 12) caso a tabela `usuario` esteja vazia.
