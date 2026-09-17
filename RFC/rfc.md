# Portfólio Mobile

**Engenharia de Software**

**Orientador:** Diogo Vinícius Winck

**Autor:** Maria Eduarda Nunes de Souza

10 de Março de 2026

**Versão:** 1.0

---

## Identificação

- **Título do Projeto:** Software Brava
- **Linha de Projeto:** Aplicativo.
- **Autor:** Maria Eduarda Nunes
- **Data da Proposta:** 10/03/2026
- **Versão:** 1.0

---

## 1. Visão do Produto e Impacto

Este projeto busca solucionar um problema real e crítico identificado no sistema de atendimento móvel de urgência do SAMU de Joinville, propondo o desenvolvimento de uma solução tecnológica robusta, segura e em conformidade com as diretrizes municipais e a LGPD.

### 1.1 Contexto e Problema

**Quem sofre com esse problema:**
Equipes operacionais do SAMU, gestão de saúde pública municipal.

**Em que contexto ele ocorre:**

> Quando ocorre uma solicitação ao SAMU, uma das quatro unidades disponíveis em Joinville é designada para o atendimento. Cada unidade é composta obrigatoriamente por um condutor socorrista e um técnico de enfermagem ou enfermeiro.
>
> Durante o atendimento, enquanto são prestados os primeiros socorros e o paciente é estabilizado e encaminhado à unidade hospitalar, a equipe assistencial precisa preencher manualmente uma ficha técnica extensa. O documento físico reúne dados clínicos, histórico prévio, intervenções realizadas e horários de deslocamento.
>
> Ao término da ocorrência, uma via física é entregue ao hospital recebedor e outra via permanece na base do SAMU para posterior digitação e consolidação nos registros da Secretaria Municipal de Saúde. O processo manual consome tempo essencial da equipe assistencial, apresenta riscos de ilegibilidade na grafia e atrasa a disponibilidade de dados epidemiológicos em tempo real.

**Como esse problema é resolvido atualmente:**

> O Software Brava propõe resolver essa lacuna operacional por meio de um ecossistema multiplataforma: um aplicativo móvel em Flutter voltado para tablets em campo com arquitetura *Offline-First*, permitindo o preenchimento ágil, validação imediata e geração de fichas digitais, associado a um painel web administrativo (Flutter Web) para monitoramento em tempo real, auditoria e gestão do corpo clínico. Os dados consolidados sincronizam de forma segura e assíncrona com a base de dados da Prefeitura de Joinville.

**Quais são as limitações das soluções atuais:**

> As soluções proprietárias existentes no mercado apresentam alto custo de licenciamento contínuo para a administração pública, operam em silos proprietários com baixa interoperabilidade com a infraestrutura municipal existente e foram desenhadas para fluxos administrativos externos que não refletem a dinâmica e os protocolos locais de Joinville.

### 1.2 Origem da Demanda e Evidências

**Contexto da demanda:**

> Serviço de Atendimento Móvel de Urgência (SAMU):

**Descrição do problema relatado:**

> Durante o atendimento a um paciente, a equipe da unidade móvel precisa preencher uma ficha técnica que deve ser entregue ao hospital de destino, além de manter uma cópia arquivada na unidade responsável pela ambulância. Esse processo manual aumenta o tempo gasto com documentação, podendo impactar na agilidade das equipes.
>
> Com o objetivo de otimizar esse processo, propõe-se o desenvolvimento de um aplicativo que permitirá o registro digital das informações do atendimento. Dessa forma, a ficha técnica poderá ser preenchida de maneira mais prática e rápida, gerando automaticamente um arquivo pronto para envio aos hospitais e armazenamento digital, reduzindo o tempo de preenchimento e facilitando a gestão das informações.

**Pesquisa com Usuários:**

> A pesquisa com usuários teve início por meio de uma entrevista presencial realizada na universidade Católica, na qual um representante da Prefeitura realizou a primeira apresentação em um contexto geral da necessidade. A segunda foi realizada na Prefeitura, na qual foi apresentado, de forma detalhada, o processo atual de preenchimento da ficha.
>
> A entrevista contou com a participação de uma funcionária do órgão de saúde e da estudante responsável pelo desenvolvimento do sistema. Durante esse momento, a funcionária pública explicou o significado de cada campo abreviado, destacou informações críticas que exigem maior atenção e demonstrou, na prática, como deve ser realizado o preenchimento correto.
>
> Durante a condução da entrevista, foram realizadas perguntas-chave, como:
>
> - "Quais são as maiores dificuldades enfrentadas no preenchimento das fichas?"
> - "Quais campos geram mais dúvidas ou erros?"
> - "Como é feito atualmente o armazenamento e controle dessas informações?"
> - "De que forma o sistema ideal deveria apresentar essas informações em formato digital?"
>
> Como respostas, identificou-se que o processo manual demanda muito tempo, principalmente devido ao preenchimento em papel, seguido da necessidade de contabilização e digitalização para controle interno. Também foi apontado como problema o armazenamento físico das fichas, que ocupa espaço e dificulta o acesso rápido às informações.
>
> Além disso, ao analisar conjuntamente a ficha, a usuária explicou o significado de todos os campos e indicou quais poderiam ser padronizados ou simplificados. A partir dessas respostas, foi possível tomar decisões importantes de design, como a substituição de campos abertos por botões de múltipla escolha, visando reduzir erros e aumentar a agilidade no preenchimento.
>
> Outro ponto levantado durante a entrevista foi a necessidade de estruturar o sistema em telas bem organizadas, definindo claramente quais informações devem aparecer em cada etapa do preenchimento. Essa discussão influenciou diretamente a modelagem da interface do aplicativo.
>
> Por fim, a usuária sugeriu a integração com GPS, o que foi considerado como um requisito adicional relevante, podendo contribuir para a coleta automática de localização e maior precisão dos dados registrados.
>
> O desenvolvimento do aplicativo foi previsto para ocorrer ao longo de um período estimado de um ano, considerando as etapas de levantamento de requisitos, prototipação, implementação e validação com os usuários.

**Evidência de Interesse:**

> Não foi realizada uma pesquisa inicial formal, uma vez que ocorreu uma reunião com agentes diretos da Prefeitura em nossa universidade. Nessa ocasião, foi apresentada a principal demanda enfrentada, relacionada ao tempo gasto no preenchimento, leitura, digitalização e gestão das informações nas unidades básicas de socorro de Joinville.
>
> Observou-se que essa dificuldade não é exclusiva do município, sendo também compartilhada por outras cidades e estados, como São Paulo. Nesse contexto, foi identificado que o estado de São Paulo contratou os serviços de uma empresa privada para desenvolver uma aplicação com o objetivo de otimizar o preenchimento de fichas, além de criar soluções digitais para apoiar o cotidiano de professores da rede pública.
>
> Entretanto, tais aplicações são pagas e voltadas para demandas específicas do estado de São Paulo, o que limita sua adoção em outros contextos.

### 1.3 Análise de Soluções Existentes (Benchmark)

**Nome do Produto:** IDS SAMU

**Link:** https://play.google.com/store/apps/details?id=br.inf.ids.samuapp

**Público-alvo:**

> Funcionários de Prefeituras e funcionários de dentro das unidades básicas de socorro móvel, como técnicos de enfermagem e motoristas.

**Funcionalidades principais:**

> Otimizar o tempo de preenchimento da ficha técnica de papel hoje.

**Limitações:**

> Ser pago e estrutura focada para o sistema de São Paulo.

> *[Figura: Imagem ilustrando aplicativo no PlayStore — `id samu.jpg`]*

**Comparação:**

> O referido software é voltado exclusivamente para prefeituras, sendo cobrado um valor específico que varia conforme cada município. Assim, é perceptível também que ele utiliza um sistema próprio de acesso, baseado em códigos individuais por usuário, além de disponibilizar um endereço HTTP específico para cada prefeitura.

> *[Figura: Imagem ilustrando tela inicial do software — `Captura.png`]*

**Objetivo para criar algo novo:**

> Foi observado que o acesso para verificação de orçamentos nos sistemas atuais é demorado e pouco eficiente. Além disso, trata-se de um software robusto, desenvolvido com foco nas necessidades do estado de São Paulo, o que nem sempre se adequa à realidade local. A proposta é desenvolver uma solução específica para a prefeitura de Joinville, voltada às necessidades das quatro unidades do SAMU, com acesso simplificado e foco nas demandas do dia a dia das equipes locais.

**Qual lacuna não foi resolvida pelas soluções existentes:**

> Embora as soluções atuais atendam às demandas de forma geral, elas apresentam funcionalidades além do necessário para as unidades de Joinville, tornando o uso mais complexo do que o ideal. Além disso, o custo elevado dessas ferramentas as torna inviáveis para a realidade local.

**Qual nicho específico será atendido:**

> O objetivo do software será direcionado às unidades de saúde móvel de Joinville, especialmente às equipes do SAMU, atendendo de forma específica às suas rotinas e necessidades operacionais.

### 1.4 Público-Alvo

**Defina quem usará o sistema:**

Os usuários do sistema são segmentados conforme a responsabilidade:

- **Administrador Municipal:** Acesso exclusivo via navegador Web ao painel de indicadores, relatórios consolidados e módulo de gerenciamento de unidades e usuários.
- **Corpo Assistencial (Enfermeiro, Técnico de Enfermagem e Condutor Socorrista):** Acesso via aplicativo móvel autenticado individualmente com redirecionamento direto para a coleta e emissão da ficha técnica.

### 1.5 Objetivos do Projeto

**Objetivo Geral:**

> Otimizar o ciclo de registro e arquivamento das fichas de socorro do SAMU de Joinville por meio de um sistema móvel e web escalável, seguro e integrado à base municipal.

**Objetivos Específicos:**

- Eliminar o preenchimento manual em papel e reduzir a zero o tempo gasto com digitação secundária.
- Assegurar a continuidade do registro mesmo em zonas de sombra de conectividade (*Offline-First*).
- Prover um painel gerencial em tempo real para tomada de decisão epidemiológica e logística da saúde pública.
- Garantir conformidade estrita com a LGPD (Lei 13.709/2018) para dados pessoais sensíveis de saúde.

### 1.6 Métricas de Sucesso (KPIs)

- **Taxa de erros no preenchimento:** Redução significativa de inconsistências por meio de validação sintática em tempo real e campos normalizados.
- **Tempo de ciclo da documentação:** Redução de pelo menos 60% no tempo despendido pelos socorristas com burocracia clínica.
- **Disponibilidade do Serviço (*Uptime*):** Índice de 99,5% de disponibilidade da API central na infraestrutura municipal.
- **Confiabilidade de Sincronização:** 100% de integridade dos pacotes gerados em modo offline persistidos sem perda transacional.

---

## 2. Engenharia de Requisitos

### 2.1 Personas

> Solução é direcionada às unidades de saúde móvel de Joinville, especialmente às equipes do SAMU, atendendo de forma específica às suas rotinas e necessidades operacionais.

**Administrador: Marina**
É o administrador da saúde na prefeitura. Seu objetivo é gerenciar todas as unidades semanalmente, acompanhando os atendimentos de cada uma delas.

**Motorista: Gregório**
É o motorista da unidade móvel Brava 2. Seu objetivo é conduzir a equipe (técnico e enfermeiro) até o local da ocorrência e, posteriormente, transportar o paciente até o hospital com segurança.

**Técnica de Enfermagem: Ana**
É técnica de enfermagem da unidade móvel Brava 2. Seu objetivo é prestar os primeiros socorros e auxiliar o enfermeiro durante o atendimento.

**Enfermeiro: Joaquim**
É o enfermeiro da unidade móvel Brava 2. Seu objetivo é prestar os primeiros socorros e coordenar os procedimentos de atendimento ao paciente.

**Médico**
Perfil referenciado no cadastro, mas sem acesso à ficha e sem acesso ao ambiente de administrador.

### 2.2 Casos de Uso Principais

> O software será direcionado às unidades de saúde móvel de Joinville, especialmente às equipes do SAMU, atendendo de forma específica às suas rotinas e necessidades operacionais.

> *[Figura: Diagrama de casos de uso do perfil Administrador, contemplando acesso completo ao sistema incluindo gestão de usuários e número de chamados por unidade — `caso1.png`]*

> *[Figura: Diagrama de casos de uso do perfil Técnico de Enfermagem, o Enfermeiro ou o Motorista, acessando o portal para preencher o formulário sobre o atendimento realizado — `Diagrama dois.png`]*

### 2.3 Requisitos Funcionais (RF)

| Código | Descrição |
|---|---|
| RF01 | O sistema deve permitir o registro digital de atendimentos realizados pelas unidades do SAMU. |
| RF02 | O sistema deve permitir o uso de campos de múltipla escolha para reduzir erros no preenchimento. |
| RF03 | O sistema deve validar automaticamente os dados inseridos (campos obrigatórios, formatos, etc.). |
| RF04 | O sistema deve preservar as informações parcialmente preenchidas em caso de interrupção, garantindo que o profissional possa retomar o preenchimento sem perda de dados. |
| RF05 | O sistema deve permitir o funcionamento offline. |
| RF06 | O sistema deve integrar os dados salvos de cada ficha preenchida com o banco da Prefeitura. |
| RF07 | O sistema deve permitir a geração de relatórios de atendimentos. |
| RF08 | O sistema deve permitir a busca de registros por data ou unidade. |
| RF09 | O sistema deve registrar as coordenadas geográficas do local do atendimento. |
| RF10 | O sistema deve permitir o cadastro de novos médicos, Unidades Básicas, técnicos de enfermagem, condutores socorristas e enfermeiros pelo Administrador. |
| RF11 | O sistema deve permitir adicionar, no início da ficha, a informação se a unidade está parada e, em caso afirmativo, o motivo da parada. |
| RF12 | O sistema deve registrar as unidades móveis no dashboard de monitoramento de paradas. |
| RF13 | O sistema deve apresentar, no dashboard, métricas sobre o número de atendimentos realizados. |
| RF14 | O sistema deve apresentar, no dashboard, métricas relacionadas à faixa etária dos pacientes. |
| RF15 | O sistema deve apresentar, no dashboard, métricas sobre os locais com maior ocorrência de atendimentos. |
| RF16 | O sistema deve apresentar, no dashboard, métricas sobre o tempo médio de resposta das unidades. |

### 2.4 Requisitos Não Funcionais (RNF)

| Código | Descrição |
|---|---|
| RNF01 | O sistema deve carregar as páginas principais em até 5 segundos em condições normais de uso. |
| RNF02 | O sistema deve exigir autenticação para acesso às funcionalidades restritas. |
| RNF03 | O sistema deve armazenar e processar apenas os dados necessários à finalidade proposta, em conformidade com a LGPD, garantindo minimização e proteção dos dados utilizados. |
| RNF04 | O código-fonte deve ser estruturado de forma modular, facilitando manutenção e evolução futura. |
| RNF05 | O sistema deve registrar logs de execução, erros de processamento e falhas de integração, permitindo rastreabilidade e auditoria técnica. |
| RNF06 | O sistema deve funcionar nos principais navegadores atuais. |
| RNF07 | O sistema deve adotar comunicação segura entre cliente e servidor por meio de HTTPS. |
| RNF08 | O sistema deve permitir a exportação dos dados da ficha preenchida em formato PDF. |
| RNF09 | Pipeline automatizada de CI/CD com testes unitários e de integração. |

### 2.5 Regras de Negócio

| Código | Descrição |
|---|---|
| RN01 | Perfis de Usuário: o sistema deve possuir perfis distintos de Administrador e do funcionário que irá preencher a ficha, podendo ser o enfermeiro ou o Técnico de enfermagem. |
| RN02 | Obrigatoriedade da Ficha: Todo atendimento realizado deve possuir obrigatoriamente uma ficha técnica preenchida antes do encerramento da ocorrência. |
| RN03 | Validação de Campos Críticos: Campos considerados essenciais devem ser obrigatórios para finalização da ficha. |
| RN04 | Padronização de Dados: Sempre que possível, o preenchimento deve utilizar opções pré-definidas para garantir padronização das informações. |
| RN05 | Registro de Geolocalização: localização (GPS) deve ser registrada automaticamente pelo sistema. |
| RN06 | Sincronização de Dados: Quando offline, os dados devem ser armazenados localmente e sincronizados automaticamente quando houver conexão com a internet. |
| RN07 | Integridade dos Dados: Após o envio e finalização do preenchimento da ficha, os dados da ficha não podem ser alterados. |
| RN08 | Consulta de Histórico: O sistema deve permitir consulta de atendimentos anteriores para apoio em análises e auditorias. |
| RN09 | Geração de Relatórios: Os relatórios devem ser gerados com base nos atendimentos registrados. |
| RN10 | O sistema deve exibir, na tela inicial da ficha de atendimento, um campo obrigatório de seleção do profissional responsável pelo preenchimento, listando apenas os profissionais cadastrados. |
| RN11 | Identificação do médico de plantão: A ficha de atendimento deve registrar obrigatoriamente o nome do médico responsável pelo plantão no momento da saída da unidade. Esse campo é selecionado a partir do cadastro de médicos mantido pelo Administrador. |
| RN12 | Toda ficha de atendimento deve conter obrigatoriamente a identificação do médico responsável pelo plantão no momento da saída da unidade. |
| RN13 | O sistema deve permitir o cadastro e autenticação de usuários com diferentes perfis: <br> a) Administrador com login e senha; <br> b) Enfermeiro, Condutores Socorristas e Técnico acessam com senha e login. Login deve ser padrão para as 4 unidades bravas. |

### 2.6 Fora do Escopo

O sistema não realizará diagnósticos, recomendações médicas ou qualquer tipo de análise clínica automatizada, sendo toda responsabilidade de avaliação e conduta atribuída aos profissionais envolvidos no atendimento.

Não faz parte do escopo do sistema o gerenciamento completo de prontuários hospitalares ou integração com todos os sistemas internos dos hospitais, limitando-se à impressão do registro da ficha técnica de atendimento para deixar no hospital.

O sistema não contemplará funcionalidades relacionadas à gestão operacional do SAMU, como despacho de viaturas, controle de rotas, monitoramento de frota ou alocação de equipes.

Não será responsabilidade do sistema garantir conectividade com a internet em campo, sendo o funcionamento offline limitado ao armazenamento local com sincronização posterior quando houver conexão disponível.

O sistema não substituirá processos legais ou obrigatórios que eventualmente exijam documentação física, ficando sua utilização sujeita às normas e regulamentações vigentes do município.

O sistema não incluirá funcionalidades avançadas de análise de dados, Business Intelligence ou geração de indicadores estratégicos complexos, limitando-se à geração de relatórios operacionais básicos.

Por fim, o sistema não abrangerá integração com dispositivos médicos ou sensores externos, como equipamentos de monitoramento de sinais vitais, restringindo-se ao registro manual ou semiautomático das informações pelos profissionais.

---

## 3. Fluxos e Comportamento do Sistema

### 3.1 Fluxo Principal do Usuário

A representação gráfica a seguir descreve a sequência lógica de interação do usuário com a plataforma.

> *[Figura: Representação do fluxo completo — `Diagrama.png`]*

> *[Figura: Representação do fluxo operacional, detalhando as etapas realizadas pelo Administrador — `Diagrama admin.png`]*

> *[Figura: Representação do fluxo operacional, detalhando as etapas realizadas pelo Enfermeiro ou Técnico de Enfermagem — `Diagrama Enf.png`]*

### 3.2 Fluxos Alternativos

**FA01: Falha na Captura de GPS**
**Condição:** O dispositivo não consegue obter as coordenadas de localização no momento em que é informado o CEP.
**Resposta do sistema:** O sistema exibe um alerta de "Sinal de GPS não encontrado", solicita que o usuário tente novamente em área aberta ou permite a inserção manual justificada do endereço, registrando a pendência de localização.

**FA02: Interrupção de Preenchimento por Emergência Crítica**
**Condição:** A equipe precisa interromper o registro digital para priorizar uma intervenção imediata de suporte à vida.
**Resposta do sistema:** O usuário fecha o aplicativo ou bloqueia a tela e o sistema realiza o salvamento automático do que foi preenchido até o momento e mantém a tela em modo de espera para retomada posterior.

**FA03: Conflito de Sincronização Offline**
**Condição:** Ao recuperar a conexão, os dados locais da ficha divergem dos dados já enviados ao banco da Prefeitura.
**Resposta do sistema:** O sistema bloqueia a sobrescrita automática e mantém a versão mais completa do registro para validação manual.

---

## 4. Mockups e Experiência do Usuário (UX)

### 4.1 Fluxo de Navegação

O sistema é composto por duas interfaces distintas. A interface principal é o aplicativo móvel Android, desenvolvido em Flutter. A interface secundária é uma aplicação web em Flutter, acessada via navegador, destinada exclusivamente ao perfil Administrador para visualização do dashboard e gerenciamento de cadastros.

O esquema da Figura 5 descreve a arquitetura de navegação e o encadeamento das telas do software.

No diagrama, o Login leva diretamente para a Ficha Técnica e para o Dashboard. O Técnico/Enfermeiro, ao logar, deve ir direto para a Ficha Técnica. Enquanto o Administrador vai direto para o dashboard.

O Fluxo do Administrador mostra o caminho: Dashboard → Menu de Administrador → Cadastros. O Administrador também acessa as Fichas Técnicas para visualização.

O Fluxo do Público Geral (Técnico e Enfermeiro): o Técnico e o Enfermeiro não passam pelo Dashboard para chegar na Ficha Técnica. O fluxo deve ser: Login → Ficha Técnica. Eles não têm acesso visual ao Dashboard administrativo.

### 4.2 Wireframes ou Mockups das Telas

O software é composto por 6 telas principais, descritas a seguir com suas respectivas funcionalidades e ações disponíveis ao usuário.

> *[Figura: Representação da tela visão do Administrador e Enfermeiros — `Image 4.png`]*

A arquitetura de navegação foi projetada para segmentar as funcionalidades por categoria de usuário. Após a validação das credenciais na tela inicial, o sistema executa o redirecionamento automático: o Administrador visualiza métricas e relatórios no Dashboard, ao passo que os profissionais de ponta acessam a interface da Ficha Técnica para início imediato do registro digital.

> *[Figura: Representação da tela visão do Administrador, primeira parte do Dashboard — `tela admin.png`]*

Ao autenticar-se com perfil administrativo, o usuário é direcionado ao Dashboard gerencial. Esta interface conta com um menu lateral intuitivo que disponibiliza o acesso rápido aos módulos de Cadastro de Médicos, Cadastro de Técnico de Enfermagem e Cadastro de Condutor Socorrista, Cadastro de Unidade e Gestão de Unidades Móveis vinculadas ao SAMU.

> *[Figura: Representação da tela visão do Administrador, segunda parte do Dashboard — `tela admin Dois.png`]*

Nesta seção do dashboard são apresentadas métricas de atendimentos, incluindo volume total, faixa etária dos pacientes, locais com maior ocorrência, tempo médio de resposta das unidades e percentual de indisponibilidade das ambulâncias.

> *[Figura: Representação da tela visão do Administrador, cadastro de Médico — `cadastra medico.png`]*

O sistema disponibiliza, via menu lateral, o módulo de gerenciamento de profissionais, permitindo o redirecionamento imediato para o formulário de registro de novos médicos.

> *[Figura: Representação da tela visão do Administrador, cadastro de unidade móvel — `cadastra unidade.png`]*

Por meio do menu lateral, o administrador acessa o módulo de Gestão de Unidades, permitindo o cadastramento de novas unidades básicas móveis do SAMU.

> *[Figura: Representação da tela visão do Administrador, cadastro de enfermeiro/téc. — `cadastra enf.png`]*

Por meio do menu lateral, o administrador acessa o módulo de cadastramento de novos Técnicos de Enfermagem.

> *[Figura: Representação da tela visão do Administrador, cadastro do Condutor — `Cadastro condutor.png`]*

Por meio do menu lateral, o administrador acessa o módulo de cadastramento de novos Condutores Socorristas.

> *[Figura: Representação da tela visão do Técnico de Enfermagem ou Enfermeiro (1ª tela da ficha) — `Visão um da Ficha.png`]*

Ao realizar a autenticação com credenciais de Enfermeiro ou Técnico, o sistema executa o redirecionamento automático para a Ficha Técnica, priorizando a agilidade no início do registro do atendimento. Essa é a primeira tela da ficha.

> *[Figura: Representação da tela visão do Técnico de Enfermagem ou Enfermeiro (2ª tela da ficha) — `Image 3.png`]*

Essa é a segunda tela da ficha.

> *[Figura: Representação da tela visão do Técnico de Enfermagem ou Enfermeiro (3ª tela da ficha) — `visao 3 da ficha.png`]*

Essa é a terceira tela da ficha.

### 4.3 Fluxo de Interação do Usuário

O sistema contempla dois percursos de navegação diferenciados, adaptados às necessidades do Administrador e dos Usuários finais.

**Ator:** Administrador
**Objetivo:** Gerenciar o corpo clínico, as unidades móveis e monitorar indicadores de desempenho via Dashboard.

1. O Administrador acessa a interface de entrada e fornece suas credenciais exclusivas (login e senha) para validação.
2. O software autentica os dados e, ao identificar o nível de acesso administrativo, executa o redirecionamento automático para o Painel de Controle, o Dashboard.
3. No Dashboard, o gestor utiliza filtros cronológicos (dia, mês ou ano) para monitorar a produtividade das unidades. A interface apresenta o volume de ocorrências por unidade básica móvel e um gráfico comparativo mensal para análise de demanda consolidada.
4. O Administrador visualiza a distribuição de chamados por unidade e gráficos de tendência para apoio à tomada de decisão.
5. Através do menu lateral, o ator acessa os módulos de novo cadastro de médicos e unidades.
6. Através do menu lateral, o ator acessa os módulos de novo cadastro de novos Técnicos de Enfermagem, Enfermeiros e Condutores.

**Ator:** Técnico de Enfermagem e Enfermeiro
**Objetivo:** Autenticar-se no sistema e realizar o registro digital detalhado da ocorrência e dos dados do paciente.

1. O profissional acessa a plataforma e insere suas credenciais de acesso para validação.
2. O software valida o perfil assistencial e direciona o usuário automaticamente para a interface da Ficha Técnica, otimizando o tempo de resposta.
3. O formulário é preenchido de forma dinâmica durante o atendimento ou no trajeto para a unidade hospitalar, garantindo a integridade das informações coletadas em tempo real.

### 4.4 Feedback Inicial de Usuários (Opcional)

No dia 08/05/2026, foi realizada uma reunião com Amanda Nunes, Adriano Laemm, Nadia Cristina e Tiago Felipe. O encontro teve como objetivo a reiteração do escopo do projeto e a demonstração das funcionalidades desenvolvidas.

1. **Aprovação:** O feedback foi amplamente positivo, resultando na aprovação tanto da interface web quanto do aplicativo.
2. **Melhorias:** Foram identificados pontos de melhoria pontuais, que serão priorizados em um cronograma futuro, após a conclusão da entrega inicial.
3. **Definições de Infraestrutura:** Ficou acordado que a Prefeitura será responsável pela segurança da informação e pelo provisionamento dos servidores necessários para a sustentação do projeto.

---

## 5. Arquitetura do Sistema

### 5.1 Diagrama C4

#### Nível 1: Diagrama de Contexto

O Sistema Digital do SAMU atua como uma "caixa preta", integrando profissionais e instituições e centralizando o fluxo de informações dos atendimentos. A Equipe (enfermeiros e técnicos) registra os dados e preenche as fichas durante o atendimento, enquanto o Administrador utiliza as informações para gestão de cadastros e indicadores. O sistema também se conecta ao Banco de Dados da Prefeitura, responsável pelo armazenamento e consolidação dos dados, e ao Hospital de Destino, que recebe as fichas para dar continuidade ao atendimento. Dessa forma, o sistema organiza, processa e compartilha as informações, garantindo agilidade e eficiência no processo.

> *[Figura: Representação nível 1 — `modeloN1.png`]*

#### Nível 2: Diagrama de Containers

O Diagrama de Containers apresenta a estrutura interna do Sistema Digital do SAMU, mostrando a aplicação Web/Mobile utilizada pela equipe e administradores, a API Back-end responsável pelas regras de negócio e integrações, e o Banco de Dados para armazenamento das informações. O sistema também se integra ao Banco de Dados da Prefeitura e ao Hospital de Destino, garantindo sincronização, organização e agilidade no fluxo dos atendimentos.

> *[Figura: Representação nível 2 — `ModeloN2.png`]*

#### Nível 3: Diagrama de Componentes

O Diagrama de Componentes detalha os principais componentes internos da API do Sistema Digital do SAMU e suas responsabilidades. Entre eles estão os módulos de autenticação, gerenciamento de usuários, registro de atendimentos, controle de fichas, geração de indicadores e integração com sistemas externos. Esses componentes trabalham de forma integrada para processar os dados inseridos pela equipe assistencial, permitir o acompanhamento administrativo e garantir o envio e sincronização das informações com a prefeitura e os hospitais de destino.

> *[Figura: Representação nível 3 — `ModeloN3.png`]*

#### Nível 4: Diagrama de Código

O Diagrama de Código apresenta a implementação detalhada dos componentes do Sistema Digital do SAMU, evidenciando classes, métodos, entidades e suas relações internas. O nível demonstra como as funcionalidades de autenticação, gerenciamento de usuários, atendimentos, fichas e integrações externas são organizadas no código, garantindo manutenção, modularidade e comunicação eficiente entre as camadas do sistema.

> *[Figura: Representação nível 4 — `ModeloN4.png`]*

### 5.2 Modelo de Dados

A arquitetura de dados baseia-se no PostgreSQL, organizada em sete tabelas principais e uma tabela virtual (View) de caráter temporário para consultas específicas.

> *[Figura: Representação do banco — `tenta2.jpg`]*

### 5.3 Principais Componentes

Esta seção sintetiza as necessidades operacionais do SAMU de Joinville com a arquitetura técnica proposta.

**API (Backend):**
Desenvolvida em Python (FastAPI/Flask), atua como a ponte de comunicação segura entre o aplicativo móvel e o servidor da prefeitura. É responsável por receber os dados das fichas técnicas, validar as regras de negócio e gerenciar as requisições do Dashboard administrativo.

**Sistema de Autenticação:**
Módulo que controla o acesso baseado em perfis (RBAC). Garante que o Administrador seja redirecionado ao Dashboard de gestão e que o Enfermeiro/Técnico acesse diretamente o formulário de atendimento, assegurando a proteção dos dados sensíveis conforme a LGPD.

**Módulo de Processamento e Sincronização:**
Responsável pela lógica de "Offline-First". Gerencia o armazenamento temporário no dispositivo móvel e automatiza o envio dos dados para a nuvem assim que uma conexão de rede (Wi-Fi ou 4G) é detectada, garantindo que nenhum atendimento seja perdido por falta de sinal.

**Camada de Persistência:**
Composta por uma estrutura híbrida de banco de dados. No cliente (mobile), utiliza SQLite para persistência local imediata; no servidor central, utiliza PostgreSQL/DBeaver para o armazenamento definitivo, histórico e geração de relatórios gerenciais.

**Módulo de Coleta e Validação (Ficha Técnica Digital):**
Interface otimizada para tablets que substitui o preenchimento manual. Inclui componentes de múltipla escolha para agilizar o socorro, validação de campos críticos e integração automática com o GPS para registro de geolocalização da ocorrência.

**Painel de Gestão (Dashboard):**
Módulo secundário do projeto, acessado via interface web em Flutter pelo perfil Administrador, que processa os dados armazenados para exibir métricas de desempenho, volume de atendimentos por unidade móvel (Bravas) e ferramentas de cadastro para manutenção do corpo clínico e da frota.

### 5.4 Stack Tecnológica

- **Front-end Mobile:** Flutter (Dart) com SQLite (SQLCipher) para persistência local criptografada.
- **Front-end Web:** Flutter Web / Dashboard corporativo responsivo.
- **Back-end API:** Python 3.12+ com FastAPI e Pydantic para validação estrita.
- **Camada ORM:** SQLAlchemy 2.0 (com suporte assíncrono via `asyncpg`).
- **Banco de Dados Central:** PostgreSQL 16+ com replicação e índices otimizados.
- **Cache e Mensageria:** Redis para cache de leitura e enfileiramento de tarefas assíncronas.

---

## 6. Segurança e Privacidade

### 6.1 Privacidade e LGPD

- **Criptografia em Repouso (*At-Rest*):** Uso de AES-256 no banco local do dispositivo móvel e tabelas com colunas sensíveis encriptadas no PostgreSQL central via chaves gerenciadas de forma segura (*Key Management System*).
- **Criptografia em Trânsito (*In-Transit*):** Comunicação obrigatória via HTTPS/TLS 1.2+ com HSTS habilitado.
- **Senhas de Usuários:** Criptografia unidirecional com salt dinâmico e algoritmo *bcrypt* ou *Argon2*.

### 6.2 Armazenamento e Proteção dos Dados

- **Criptografia em Repouso (*At-Rest*):** Uso de AES-256 no banco local do dispositivo móvel e tabelas com colunas sensíveis encriptadas no PostgreSQL central via chaves gerenciadas de forma segura (*Key Management System*).
- **Criptografia em Trânsito (*In-Transit*):** Comunicação obrigatória via HTTPS/TLS 1.2+ com HSTS habilitado.
- **Senhas de Usuários:** Criptografia unidirecional com salt dinâmico e algoritmo *bcrypt* ou *Argon2*.

### 6.3 Controle de Acesso (RBAC)

O controle de acesso do sistema é estruturado sob o modelo RBAC (Role-Based Access Control), que organiza as permissões de acordo com a função de cada colaborador. Como a infraestrutura e os servidores estão sob a responsabilidade da Prefeitura, este gerenciamento deve seguir os seguintes critérios de segurança:

**Perfis de Acesso**

Administrador: Possui visão gerencial, acessando o Dashboard e os módulos de cadastro de profissionais e unidades. Pode visualizar as fichas técnicas registradas, mas não tem permissão para alterar o conteúdo de prontuários já finalizados.

Enfermeiro/Técnico de Enfermagem: Acesso restrito e operacional. Este perfil pode apenas preencher a ficha técnica de sua própria unidade, sendo impedido de visualizar o Dashboard ou registros de terceiros.

**Segurança na Navegação**

Validação via Backend: Para evitar vulnerabilidades de segurança, o redirecionamento após o login e o controle de acesso às páginas são realizados diretamente no servidor central (hospedado pela Prefeitura).

Prevenção de Manipulação: Essa arquitetura garante que um usuário não consiga acessar telas de outros perfis apenas alterando o endereço (URL) no navegador, assegurando que as regras de permissão sejam impostas de forma rígida.

### 6.4 Segurança na Transmissão

Toda comunicação entre o aplicativo (Flutter/Dart) e a API backend (Python/FastAPI) deve ocorrer exclusivamente via HTTPS com TLS 1.2 ou superior, conforme definido no RNF11 (*sic*, ver RNF07). Requisições HTTP sem criptografia devem ser rejeitadas pelo servidor.

No modo offline, os dados são armazenados localmente no dispositivo com criptografia ativa. No momento da sincronização, o sistema deve revalidar o token de autenticação do usuário antes de aceitar o envio dos dados ao servidor. Isso impede que dados capturados em modo offline sejam enviados por uma sessão expirada ou por um dispositivo não autorizado.

A API deve implementar proteção contra SQL Injection via uso do ORM SQLAlchemy (conforme previsto na seção 5.4), além de validação de entrada em todos os endpoints que recebam dados do aplicativo.

### 6.5 Logs e Rastreabilidade

Conforme o RNF09 (*sic*, ver RNF05), o sistema deve registrar logs de execução, erros de processamento e falhas de integração. Para fins de segurança e conformidade com a LGPD, os logs devem incluir:

- Identificação do indivíduo, garantida pelo campo obrigatório de identificação após acessar a ficha — o preenchedor deve informar seu nome no início da ficha, não exclusivamente pela sessão de login.
- Data, hora e ação executada (criação de ficha, login, exportação de PDF, etc.).
- Identificador da unidade e da ficha associada.

Os logs não devem registrar dados sensíveis de saúde dos pacientes, apenas metadados da operação. O acesso aos logs deve ser restrito ao perfil Administrador.

### 6.6 Direitos dos Titulares

**Pacientes:** os dados de saúde dos pacientes são registrados no exercício de uma atividade de saúde pública obrigatória. O paciente ou seu representante legal pode, junto à Prefeitura de Joinville (controladora dos dados), solicitar: acesso às informações registradas sobre si; correção de dados incorretos; e informações sobre o uso dado aos seus dados, conforme Art. 18 da LGPD.

**Usuários do sistema:** os profissionais cadastrados (enfermeiros, técnicos, motoristas, médicos) podem solicitar ao Administrador: acesso aos seus dados pessoais armazenados; correção de dados incompletos ou desatualizados; e exclusão ou inativação de seu cadastro quando desligados da unidade.

### 6.7 Governança e Responsabilidades

A Prefeitura Municipal de Joinville atua na qualidade de Controladora dos Dados, cabendo ao sistema prover os mecanismos técnicos de operador para viabilizar os direitos dos titulares (acesso, retificação e auditoria), sob supervisão do Encarregado de Dados (DPO) municipal.

---

## 7. Planejamento do Projeto

| Marco | Descrição | Prazo |
|---|---|---|
| M1 | Primeira versão do documento de especificação (RFC) e análise realizada pelo usuário final, Administrador. Foi coletado o feedback. | 08/05/2026 |
| M2 | Conclusão do documento e especificação (RFC), consolidando a análise de requisitos, o projeto de arquitetura, os protótipos de alta fidelidade e o cronograma detalhado do sistema. | 11/06/2026 |
| M3 | Coleta e ajustes de observações dos monitores | 22/06/2026 |
| M4 | Desenvolvimento do Front, a aplicação, incluindo todas as telas do usuário comum. | 19/06/2026 |
| M5 | Desenvolvimento do Front, a aplicação, incluindo todas as telas do usuário do administrador. | 17/07/2026 |
| M6 | Desenvolvimento da infraestrutura Back-end, composta por uma API RESTful de alta performance, pipelines para sincronização e validação de dados provenientes do modo offline, e uma camada de persistência robusta utilizando o ORM SQLAlchemy sobre o banco de dados PostgreSQL. | 21/08/2026 |
| M7 | Primeira visão | 18/09/2026 |
| M8 | Integração dos módulos, testes finais do sistema e entrega da versão completa do projeto. | 18/10/2026 |

---

## 8. Referências

**Legislação:**

BRASIL. Lei nº 13.709, de 14 de agosto de 2018. Lei Geral de Proteção de Dados Pessoais (LGPD). Diário Oficial da União, Brasília, DF, 15 ago. 2018. Disponível em: https://www.planalto.gov.br. Acesso em: 10 mar. 2026.

BRASIL. Ministério da Saúde. Portaria GM/MS nº 2.048, de 5 de novembro de 2002. Aprova o Regulamento Técnico dos Sistemas Estaduais de Urgência e Emergência. Diário Oficial da União, Brasília, DF, 12 nov. 2002. Disponível em: https://bvsms.saude.gov.br. Acesso em: 10 mar. 2026.

**Pesquisa de Campo e Entrevistas:**

PREFEITURA MUNICIPAL DE JOINVILLE. Entrevista com funcionária do órgão de saúde responsável pelo SAMU de Joinville. Joinville, SC, fev. 2026. Entrevista concedida à autora Maria Eduarda Nunes de Souza para fins de levantamento de requisitos do Software Brava. Registro em anotações da pesquisadora.

PREFEITURA MUNICIPAL DE JOINVILLE. Apresentação institucional sobre o processo de atendimento do SAMU de Joinville. Joinville, SC, fev. 2026. Realizada por representante da Prefeitura Municipal de Joinville no Centro Universitário Católica de Santa Catarina, para fins de levantamento de requisitos do projeto Software Brava.

**Documento Técnico Analisado:**

PREFEITURA MUNICIPAL DE JOINVILLE. Ficha técnica de atendimento do SAMU. Joinville, SC, 2026. Documento físico utilizado pelas equipes das unidades móveis de urgência para registro manual de ocorrências. Analisado pela autora durante reunião presencial com funcionária do órgão de saúde.

**Ferramentas e Tecnologias Utilizadas:**

GOOGLE. Flutter: UI toolkit for building natively compiled applications. Mountain View: Google LLC, 2026. Disponível em: https://flutter.dev. Acesso em: 10 mar. 2026.

TIANGOLO, Sebastián. FastAPI: modern, fast web framework for building APIs with Python. 2026. Disponível em: https://fastapi.tiangolo.com. Acesso em: 10 mar. 2026.

POSTGRESQL GLOBAL DEVELOPMENT GROUP. PostgreSQL: the world's most advanced open source relational database. 2026. Disponível em: https://www.postgresql.org. Acesso em: 10 mar. 2026.

SQLITE CONSORTIUM. SQLite: a C-language library that implements a small, fast, self-contained SQL database engine. 2026. Disponível em: https://www.sqlite.org. Acesso em: 10 mar. 2026.

SQLALCHEMY AUTHORS. SQLAlchemy: the Python SQL toolkit and object relational mapper. 2026. Disponível em: https://www.sqlalchemy.org. Acesso em: 10 mar. 2026.

**Aplicativo de Referência (Benchmark):**

IDS SOFTWARE. IDS SAMU. Versão disponível em 2026. Aplicativo móvel para registro de atendimentos do SAMU. São Paulo: IDS Software, 2026. Disponível em: https://play.google.com/store/apps/details?id=br.inf.ids.samuapp. Acesso em: 10 mar. 2026.

---

## 9. Apêndices

### 9.1 Protótipo de Interface

As interfaces detalhadas na seção anterior foram projetadas em alta fidelidade na ferramenta, garantindo a fidelidade visual e funcional do software. O protótipo interativo pode ser consultado via link 1 e link 2:

- https://www.figma.com/make/VmeE1TRLdNX4DjaYeRGYNl/Mobile-form-app?t=6svNult7t8KcjlZR-1&preview-route=%2Fglasgow
- https://v0.app/chat/dashboard-de-unidades-d3OGiWr3ehe?q=Adicione+uma+op%C3%A7%C3%A3o+na+laterla+do+menu+para+cadastro+de+t%C3%A9cnico+de+enfermagem%2C+e+uma+op%C3%A7%C3%A3o+para+cadastrar+um+novo+socorrista.+%0A&ref=9W2TRY

### 9.2 Diagramas e Casos de Uso

Utilizou-se a ferramenta draw.io para a elaboração dos diagramas de casos de uso e do mapa de navegação do software. Os arquivos correspondentes podem ser acessados via link:

- https://drive.google.com/file/d/1i06F5xgMuuqQa0i_XAX6pAFnFoFOrogO/view?usp=sharing

### 9.3 Diagramas C4

Os modelos estão localizados no repositório na pasta "MODELO C4":

- https://github.com/Madu3304/Software_brava.git

### 9.4 Repositório do Projeto

O código-fonte integral deste projeto será mantido em regime de acesso público, disponível nos seguintes repositórios após a conclusão do desenvolvimento:

- https://github.com/Madu3304/Software_brava.git