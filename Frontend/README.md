# 🚑 Software Brava - Frontend (SAMU 192 Joinville)

Este é o módulo de **Frontend** do projeto **Software Brava**, desenvolvido em **Flutter** para atender tanto o **Painel Administrativo Web** quanto o aplicativo da **Ficha de Atendimento Pré-Hospitalar (APH)** para as equipes de campo do SAMU 192.

---

## 📋 Pré-requisitos

Antes de iniciar, certifique-se de ter instalado em sua máquina:

1. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Versão 3.0.0 ou superior).
2. **Dart SDK** (incluído no Flutter).
3. **Navegador Google Chrome** (para execução em ambiente Web) ou **Visual Studio com ferramentas C++** (para Desktop Windows).
4. *(Opcional)* Emulador Android ou dispositivo físico conectado com depuração USB ativada.

Verifique se o seu ambiente Flutter está pronto executando no terminal:
```bash
flutter doctor
```

---

## 🚀 Como Executar o Projeto

Siga o passo a passo abaixo para rodar a aplicação:

### 1. Clonar o repositório e entrar na pasta do Frontend
Se ainda não estiver na pasta do projeto:
```bash
cd c:\Users\User\Documents\modeloC4\Software_brava\Frontend
```
*(ou apenas `cd Frontend` a partir da raiz do repositório).*

### 2. Instalar as dependências do Flutter
Baixe todos os pacotes necessários especificados no `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Verificar dispositivos disponíveis
Para ver os navegadores e dispositivos conectados:
```bash
flutter devices
```

### 4. Executar a aplicação

* **Para rodar no Navegador (Web / Google Chrome) - Recomendado:**
  ```bash
  flutter run -d chrome
  ```

* **Para rodar como aplicativo Windows Desktop:**
  ```bash
  flutter run -d windows
  ```

* **Para rodar no Edge:**
  ```bash
  flutter run -d edge
  ```

---

## 🔑 Credenciais de Acesso (Perfis de Usuário)

O sistema possui controle de acesso baseado em perfil (RBAC) com redirecionamento automático a partir da **Tela de Login**:

| Perfil de Acesso | Usuário / Login | Senha | Destino / Tela |
| :--- | :--- | :--- | :--- |
| **Administrador (Web)** | `admin` | `admin123` | **Dashboard Administrativo Web** (`/dashboard`) |
| **Equipe de Campo (Ficha)** | `enfermeiro` | `brava123` | **Ficha de Atendimento APH** (`/ficha`) |

> 💡 **Nota:** Qualquer login ou senha contendo `adm` direciona para a visão do Administrador. Qualquer outra credencial operacional direciona para a Ficha de Atendimento.

---

## 📱 Telas e Funcionalidades

### 1. 🛡️ Painel Administrativo Web (`/dashboard`)
* **Dashboard de Indicadores:** Métricas de tempo de resposta, volume de atendimentos e taxa de sobrevivência.
* **Módulo de Cadastros:**
  * Cadastro de Médicos (com CRM e especialidade).
  * Cadastro de Técnicos de Enfermagem (com COREN).
  * Cadastro de Condutores Socorristas (com CNH e categoria).
  * Cadastro de Unidades Móveis / Ambulâncias (USB e USA).

### 2. 🚑 Ficha de Atendimento APH (`/ficha` e `/registro-ficha`)
* **Etapa 1 - Triagem e Viatura:**
  * Seleção do tipo de viatura (**USB** / USA).
  * Classificação de Risco pelo Protocolo de Manchester (**Vermelho**, **Amarelo**, **Verde**, **Azul**).
* **Etapa 2 - Registro da Ocorrência:**
  * Número do registro/chamado.
  * Seleção da Base Operacional (Base Central, Sul, Norte, etc.).
  * Data do atendimento via calendário nativo.
  * Vinculação do Técnico de Enfermagem e Condutor Socorrista.
  * Finalização e geração do comprovante para impressão térmica.

---

## 🧪 Como Executar os Testes Automatizados

O projeto conta com uma suíte de testes unitários e testes de widgets para validação contínua:

```bash
# Executa todos os testes do Frontend
flutter test

# Executa apenas os testes das telas e widgets
flutter test test/views/
```

---

## 🏗️ Estrutura de Pastas (`lib/`)

O código segue os princípios de Engenharia de Software (Clean Architecture / Separação de Camadas):

```plaintext
lib/
├── core/                  # Utilitários, rotas, banco local (DatabaseHelper) e cores
│   ├── constants/         # AppRoutes, AppColors
│   └── database/          # Configuração SQLite nativo
├── models/                # Classes de dados puras e DTOs (sem widgets de interface)
│   ├── ficha_model.dart
│   ├── profissional_model.dart
│   ├── unidade_model.dart
│   └── usuario_model.dart
├── services/              # Regras de negócio, autenticação, persistência e impressão
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── print_service.dart
├── views/                 # Interfaces gráficas organizadas por contexto
│   ├── auth/              # Tela de Login do SAMU
│   ├── admin/             # Dashboard e telas de Cadastros
│   ├── assistencial/      # Ficha de Atendimento, Registro e Comprovante
│   └── shared/            # Componentes reutilizáveis
└── main.dart              # Ponto de entrada do Flutter e configuração de rotas
```
