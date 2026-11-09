from pydantic import BaseModel, Field, EmailStr, ConfigDict, model_validator
from typing import Optional, List, Dict, Any, Literal, Union
from datetime import datetime, date
import re

# ==========================================
# UTILITÁRIOS DE VALIDAÇÃO E LGPD (B24, B25)
# ==========================================

def validar_formato_cpf(cpf: Optional[str]) -> bool:
    """Valida algoritmo oficial de CPF (11 dígitos numéricos com dígitos verificadores)."""
    if not cpf:
        return True
    digitos = re.sub(r"\D", "", str(cpf))
    if len(digitos) != 11:
        # Se for outro tipo de documento (RG, passaporte), permite se não tiver formato estrito de CPF
        if re.match(r"^\d{3}\.\d{3}\.\d{3}-\d{2}$", str(cpf).strip()):
            return False
        return True
    # Rejeita sequências com todos dígitos iguais (ex: 111.111.111-11)
    if digitos == digitos[0] * 11:
        return False
    # Primeiro dígito verificador
    soma = sum(int(digitos[i]) * (10 - i) for i in range(9))
    resto = (soma * 10) % 11
    d1 = 0 if resto == 10 else resto
    if d1 != int(digitos[9]):
        return False
    # Segundo dígito verificador
    soma = sum(int(digitos[i]) * (11 - i) for i in range(10))
    resto = (soma * 10) % 11
    d2 = 0 if resto == 10 else resto
    return d2 == int(digitos[10])

def mascarar_documento_lgpd(doc: Optional[str]) -> Optional[str]:
    """Mascara documento conforme LGPD para proteção de dados pessoais (ex: ***.456.789-**)."""
    if not doc:
        return doc
    digitos = re.sub(r"\D", "", str(doc))
    if len(digitos) == 11:
        return f"***.{digitos[3:6]}.{digitos[6:9]}-**"
    if len(doc) > 4:
        return f"***{doc[-4:]}"
    return "***"

def calcular_idade_de_nascimento(data_nasc: Optional[datetime]) -> Optional[int]:
    """Calcula a idade dinâmica a partir da data de nascimento eliminando redundância (B24)."""
    if not data_nasc:
        return None
    hoje = date.today()
    dt = data_nasc.date() if isinstance(data_nasc, datetime) else data_nasc
    return hoje.year - dt.year - ((hoje.month, hoje.day) < (dt.month, dt.day))

# Tipos literais para enums padronizados (B25)
PerfilUsuario = Literal["ADMINISTRADOR", "ENFERMEIRO", "TECNICO", "CONDUTOR"]
StatusUnidade = Literal["DISPONIVEL", "EM_ATENDIMENTO", "PARADA", "MANUTENCAO"]
SexoPaciente = Literal["M", "F", "O"]

# ==========================================
# SCHEMAS DE AUTENTICAÇÃO E USUÁRIOS
# ==========================================

class LoginRequest(BaseModel):
    login: str
    senha: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    id_usuario: int
    nome: str
    login: str
    perfil: PerfilUsuario
    redirecionamento: str # 'WEB' (para Administrador) ou 'MOBILE' (para equipe de campo)

class TrocarSenhaRequest(BaseModel):
    login: str
    senha_atual: str
    nova_senha: str = Field(..., min_length=8, description="Mínimo de 8 caracteres")

class UsuarioBase(BaseModel):
    nome: str
    email: Optional[EmailStr] = None
    login: str
    perfil: PerfilUsuario
    registro_profissional: Optional[str] = None # CRM, COREN, CNH
    ativo: bool = True

class UsuarioCreate(UsuarioBase):
    senha: str

class UsuarioUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[EmailStr] = None
    perfil: Optional[PerfilUsuario] = None
    registro_profissional: Optional[str] = None
    ativo: Optional[bool] = None
    senha: Optional[str] = None

class UsuarioResponse(UsuarioBase):
    id_usuario: int
    trocar_senha: bool = False
    criado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

# ==========================================
# SCHEMAS DE CADASTROS ADMINISTRATIVOS (RF10, B22)
# ==========================================

class MedicoBase(BaseModel):
    nome: str
    codigo_medico: Optional[int] = None # CRM ou código de identificação

class MedicoCreate(MedicoBase):
    pass

class MedicoResponse(MedicoBase):
    id_medico: int
    criado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class TecnicoBase(BaseModel):
    nome: str
    codigo_tecnico: Optional[int] = None # Código / COREN do técnico
    codigo_medico: Optional[int] = None # Retrocompatibilidade com versões anteriores

    @model_validator(mode="after")
    def sincronizar_codigo_tecnico(self):
        if self.codigo_tecnico is None and self.codigo_medico is not None:
            self.codigo_tecnico = self.codigo_medico
        elif self.codigo_medico is None and self.codigo_tecnico is not None:
            self.codigo_medico = self.codigo_tecnico
        return self

class TecnicoCreate(TecnicoBase):
    pass

class TecnicoResponse(TecnicoBase):
    id_tecnico: int
    criado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class CondutorBase(BaseModel):
    nome: str
    codigo_condutor: Optional[int] = None # Código / CNH do condutor

class CondutorCreate(CondutorBase):
    pass

class CondutorResponse(CondutorBase):
    id_condutor: int
    criado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class UnidadeMovelBase(BaseModel):
    placa: Optional[str] = None
    base_unidade: str = "DISPONIVEL" # Ex: 'Brava 1', 'Brava 2'
    status: StatusUnidade = "DISPONIVEL"
    motivo_parada: Optional[str] = None

class UnidadeMovelCreate(UnidadeMovelBase):
    pass

class UnidadeMovelResponse(UnidadeMovelBase):
    id_unidade: int
    atualizado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class BaseOperacionalBase(BaseModel):
    """Modelo de Base Operacional (B22: campos próprios de base física/sede)."""
    nome: Optional[str] = None
    endereco: Optional[str] = None
    bairro: Optional[str] = None
    telefone: Optional[str] = None
    ativo: bool = True
    # Campos retrocompatíveis para evitar quebra em payloads anteriores
    placa: Optional[str] = None
    base_unidade: Optional[str] = None
    status: Optional[str] = None
    motivo_parada: Optional[str] = None

class BaseOperacionalCreate(BaseOperacionalBase):
    pass

class BaseOperacionalResponse(BaseOperacionalBase):
    id_base: int
    atualizado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class HospitalDestinoBase(BaseModel):
    nome: str
    endereco: Optional[str] = None

class HospitalDestinoCreate(HospitalDestinoBase):
    pass

class HospitalDestinoResponse(HospitalDestinoBase):
    id_hospital: int

    model_config = ConfigDict(from_attributes=True)

class PacienteBase(BaseModel):
    nome: Optional[str] = None
    idade: Optional[int] = Field(None, ge=0, le=130)
    sexo: Optional[SexoPaciente] = None
    documento: Optional[str] = None
    data_nascimento: Optional[datetime] = None
    acompanhante: Optional[str] = None
    grau_parentesco: Optional[str] = None
    telefone_acompanhante: Optional[str] = None
    gravidade_previa: Optional[str] = None
    historico_clinico: Optional[str] = None
    alergias: Optional[str] = None
    medicamentoUso_paciente: Optional[str] = None
    observacao_paciente: Optional[str] = None

    @model_validator(mode="after")
    def validar_e_calcular_paciente(self):
        # Validação do CPF se informado (B24)
        if self.documento and not validar_formato_cpf(self.documento):
            raise ValueError(f"Documento/CPF informado '{self.documento}' é inválido pelos critérios da Receita Federal.")
        # Cálculo automático da idade caso data de nascimento seja informada
        if self.data_nascimento:
            idade_calc = calcular_idade_de_nascimento(self.data_nascimento)
            if idade_calc is not None:
                self.idade = idade_calc
        return self

class PacienteCreate(PacienteBase):
    pass

class PacienteResponse(PacienteBase):
    id_paciente: int
    criado_em: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

# ==========================================
# SCHEMAS DE UTENSÍLIOS GASTOS E REPOSIÇÃO
# ==========================================

class UtensiliosGastosSchema(BaseModel):
    id_utensilios: Optional[int] = None
    medicamentos_ampolas: bool = False
    medicamentos_controlados: bool = False
    medicamentos_comprimidos: bool = False
    medicamentos_frascoGotas: bool = False
    anestesico: bool = False
    material_infusao: bool = False
    material_sondagem: bool = False
    material_trauma: bool = False
    materiais_diversos: bool = False
    observacoes_reposicao: Optional[str] = None
    reposto: bool = False
    data_reposicao: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class MarcarReposicaoRequest(BaseModel):
    reposto: bool = True
    observacoes_reposicao: Optional[str] = None

# ==========================================
# SCHEMAS DE AVALIAÇÃO CLÍNICA (B25, B26)
# ==========================================

class AvaliacaoClinicaResumoSchema(BaseModel):
    id_avaliacao: Optional[int] = None
    pressao_arterial: Optional[str] = "N/A"
    frequencia_cardiaca: Optional[int] = Field(None, ge=20, le=300, description="Frequência Cardíaca (bpm)")
    frequencia_respiratoria: Optional[int] = Field(None, ge=5, le=60, description="Frequência Respiratória (rpm)")
    saturacao_o2: Optional[int] = Field(None, ge=40, le=100, description="Saturação periférica de O2 (%)")
    glicemia: Optional[int] = Field(None, ge=10, le=800, description="Glicemia capilar (mg/dL)")
    temperatura: Optional[float] = Field(None, ge=25.0, le=45.0, description="Temperatura axilar (°C)")
    escala_glasgow: Optional[int] = Field(None, ge=3, le=15, description="Escore total de Glasgow (3-15)")
    abertura_ocular: Optional[int] = Field(None, ge=1, le=4, description="Glasgow: Abertura Ocular (1-4)")
    resposta_verbal: Optional[int] = Field(None, ge=1, le=5, description="Glasgow: Resposta Verbal (1-5)")
    resposta_motora: Optional[int] = Field(None, ge=1, le=6, description="Glasgow: Resposta Motora (1-6)")
    hemoglicoteste: Optional[int] = Field(None, ge=10, le=800, description="Hemoglicoteste (mg/dL)")
    hora_ictus: Optional[datetime] = None
    nome_testemunha: Optional[str] = None
    usa_anticoagulante: Optional[bool] = None
    assimetria_facial: Optional[bool] = None
    queda_braco: Optional[bool] = None
    fala: Optional[bool] = None
    avc_suspeito: Optional[bool] = None
    material_retido: Optional[bool] = None
    anotacao_CondutaEnfermeiro: Optional[str] = None
    procedimentos_realizados: Optional[str] = None
    medicacoes_administradas: Optional[str] = None
    conduta: Optional[str] = None

    @model_validator(mode="after")
    def validar_glasgow_e_glicemia(self):
        # Validação da consistência da escala de Glasgow (B26)
        ao, rv, rm = self.abertura_ocular, self.resposta_verbal, self.resposta_motora
        if ao is not None and rv is not None and rm is not None:
            soma = ao + rv + rm
            if self.escala_glasgow is not None and self.escala_glasgow != soma:
                raise ValueError(
                    f"A soma dos componentes de Glasgow ({ao} + {rv} + {rm} = {soma}) "
                    f"não confere com a pontuação total informada ({self.escala_glasgow})."
                )
            if self.escala_glasgow is None:
                self.escala_glasgow = soma
        # Sincroniza glicemia e hemoglicoteste
        if self.glicemia is None and self.hemoglicoteste is not None:
            self.glicemia = self.hemoglicoteste
        elif self.hemoglicoteste is None and self.glicemia is not None:
            self.hemoglicoteste = self.glicemia
        return self

    model_config = ConfigDict(from_attributes=True)

# ==========================================
# SCHEMAS DE FICHA DE ATENDIMENTO
# ==========================================

class FichaAtendimentoCreate(BaseModel):
    # O profissional responsável (RN10) é o usuário do token; não é enviado no corpo.
    uuid_offline: Optional[str] = None
    id_unidade: int
    id_condutor: Optional[int] = None
    id_paciente: Optional[int] = None
    id_tecnico: Optional[int] = None
    id_medico: Optional[int] = None
    id_base: Optional[int] = None
    id_hospital: Optional[int] = None

    # Localização / GPS
    cep: Optional[str] = None
    logradouro: Optional[str] = None
    bairro: Optional[str] = None
    numero: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    gps_endereco_destino: bool = False

    # Horários operacionais
    hora_chamado: Optional[datetime] = None
    hora_saida_base: Optional[datetime] = None
    hora_chegada_local: Optional[datetime] = None
    hora_saida_local: Optional[datetime] = None
    hora_chegada_hospital: Optional[datetime] = None
    hora_conclusao: Optional[datetime] = None

    # Status e parada
    codigo_local: Optional[str] = None
    unidade_parada: bool = False
    motivo_unidade_parada: Optional[str] = None
    observacoes_gerais: Optional[str] = None

    # Objetos aninhados opcionais na criação direta da ficha
    paciente: Optional[PacienteCreate] = None
    avaliacao_clinica: Optional[AvaliacaoClinicaResumoSchema] = None
    utensilios_gastos: Optional[UtensiliosGastosSchema] = None

    @model_validator(mode="after")
    def validar_cronologia_horarios(self):
        hc = self.hora_chamado
        hsb = self.hora_saida_base
        hcl = self.hora_chegada_local
        hsl = self.hora_saida_local
        hch = self.hora_chegada_hospital
        hconc = self.hora_conclusao

        if hc and hsb and hsb < hc:
            raise ValueError("A hora de saída da base não pode ser anterior à hora do chamado.")
        if hc and hcl and hcl < hc:
            raise ValueError("A hora de chegada ao local não pode ser anterior à hora do chamado.")
        if hsb and hcl and hcl < hsb:
            raise ValueError("A hora de chegada ao local não pode ser anterior à hora de saída da base.")
        if hcl and hsl and hsl < hcl:
            raise ValueError("A hora de saída do local não pode ser anterior à hora de chegada ao local.")
        if hsl and hch and hch < hsl:
            raise ValueError("A hora de chegada ao hospital não pode ser anterior à hora de saída do local.")
        if hcl and hconc and hconc < hcl:
            raise ValueError("A hora de conclusão não pode ser anterior à hora de chegada ao local.")
        return self

class FichaResumoResponse(BaseModel):
    id_ficha: int
    nome_paciente: str
    pressao_arterial: Optional[str] = "N/A"

    model_config = ConfigDict(from_attributes=True)

class FichaDetalhadaReposicaoResponse(BaseModel):
    id_ficha: int
    uuid_offline: Optional[str] = None
    data_atendimento: Optional[datetime] = None
    status_envio_prefeitura: Optional[str] = None # 'PENDENTE', 'ENVIADO', 'ERRO' (RF06)
    protocolo_prefeitura: Optional[str] = None
    placa_unidade: Optional[str] = None
    bairro: Optional[str] = None
    nome_paciente: Optional[str] = "Não informado"
    idade_paciente: Optional[int] = None
    sexo_paciente: Optional[str] = None
    avaliacao_clinica: Optional[AvaliacaoClinicaResumoSchema] = None
    utensilios_gastos: Optional[UtensiliosGastosSchema] = None

    model_config = ConfigDict(from_attributes=True)

# ==========================================
# SCHEMAS DE SINCRONIZAÇÃO OFFLINE (SYNC)
# ==========================================

class FichaSyncItem(FichaAtendimentoCreate):
    # O profissional responsável (RN10) é o usuário do token; não é enviado no corpo.
    uuid_offline: str

class IntegracaoStatusResponse(BaseModel):
    pendentes: int
    enviados: int
    com_erro: int
    fichas_com_erro: List[Dict[str, Any]]

class IntegracaoReenvioResponse(BaseModel):
    fichas_agendadas: int
    mensagem: str

class SyncLoteRequest(BaseModel):
    fichas: List[Union[FichaAtendimentoCreate, Dict[str, Any]]]

class SyncLoteResponse(BaseModel):
    processados: int
    sucessos: int
    duplicados_ignorados: int
    erros: List[str] = []

# ==========================================
# SCHEMAS DE DASHBOARD E RELATÓRIOS (REPORT)
# ==========================================

class DashboardReposicaoResumoResponse(BaseModel):
    total_atendimentos: int
    total_pendentes_reposicao: int
    total_repostos: int
    consumo_por_categoria: Dict[str, int]

class DashboardMetricasGeraisResponse(BaseModel):
    total_atendimentos: int
    atendimentos_hoje: int
    tempo_medio_resposta_minutos: Optional[float] = None
    tempo_medio_resposta_formatado: Optional[str] = "—"
    tempo_medio_formatado: Optional[str] = "—"
    total_unidades_ativas: int
    total_unidades_paradas: int
    atendimentos_por_unidade: Dict[str, int]
    distribuicao_faixa_etaria: Dict[str, int]
    locais_maior_ocorrencia: List[Dict[str, Any]]
    reposicao_utensilios: DashboardReposicaoResumoResponse

# ==========================================
# SCHEMAS DE LOG DE AUDITORIA (RNF05)
# ==========================================

class LogAuditoriaResponse(BaseModel):
    id_log: int
    id_usuario: Optional[int] = None
    acao: str
    detalhes_metadados: Optional[str] = None
    ip_origem: Optional[str] = None
    data_hora: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
