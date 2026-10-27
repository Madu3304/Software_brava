from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

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
    perfil: str # 'ADMINISTRADOR', 'ENFERMEIRO', 'TECNICO', 'CONDUTOR'
    redirecionamento: str # 'WEB' (para Administrador) ou 'MOBILE' (para equipe de campo)

class UsuarioBase(BaseModel):
    nome: str
    email: Optional[str] = None
    login: str
    perfil: str # 'ADMINISTRADOR', 'ENFERMEIRO', 'TECNICO', 'CONDUTOR'
    registro_profissional: Optional[str] = None # CRM, COREN, CNH
    ativo: bool = True

class UsuarioCreate(UsuarioBase):
    senha: str

class UsuarioUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[str] = None
    perfil: Optional[str] = None
    registro_profissional: Optional[str] = None
    ativo: Optional[bool] = None
    senha: Optional[str] = None

class UsuarioResponse(UsuarioBase):
    id_usuario: int
    criado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

# ==========================================
# SCHEMAS DE CADASTROS ADMINISTRATIVOS (RF10)
# ==========================================

class MedicoBase(BaseModel):
    nome: str
    codigo_medico: Optional[int] = None # CRM ou código de identificação

class MedicoCreate(MedicoBase):
    pass

class MedicoResponse(MedicoBase):
    id_medico: int
    criado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

class TecnicoBase(BaseModel):
    nome: str
    codigo_medico: Optional[int] = None # Código / COREN do técnico

class TecnicoCreate(TecnicoBase):
    pass

class TecnicoResponse(TecnicoBase):
    id_tecnico: int
    criado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

class CondutorBase(BaseModel):
    nome: str
    codigo_condutor: Optional[int] = None # Código / CNH do condutor

class CondutorCreate(CondutorBase):
    pass

class CondutorResponse(CondutorBase):
    id_condutor: int
    criado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

class UnidadeMovelBase(BaseModel):
    placa: Optional[str] = None
    base_unidade: str = "DISPONIVEL" # Ex: 'Brava 1', 'Brava 2'
    status: str = "DISPONIVEL" # 'DISPONIVEL', 'EM_ATENDIMENTO', 'PARADA', 'MANUTENCAO'
    motivo_parada: Optional[str] = None

class UnidadeMovelCreate(UnidadeMovelBase):
    pass

class UnidadeMovelResponse(UnidadeMovelBase):
    id_unidade: int
    atualizado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

class BaseOperacionalBase(BaseModel):
    placa: Optional[str] = None
    base_unidade: str = "DISPONIVEL"
    status: str = "DISPONIVEL"
    motivo_parada: Optional[str] = None

class BaseOperacionalCreate(BaseOperacionalBase):
    pass

class BaseOperacionalResponse(BaseOperacionalBase):
    id_base: int
    atualizado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

class HospitalDestinoBase(BaseModel):
    nome: str
    endereco: Optional[str] = None

class HospitalDestinoCreate(HospitalDestinoBase):
    pass

class HospitalDestinoResponse(HospitalDestinoBase):
    id_hospital: int

    class Config:
        from_attributes = True

class PacienteBase(BaseModel):
    nome: Optional[str] = None
    idade: Optional[int] = None
    sexo: Optional[str] = None # 'M', 'F', 'O'
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

class PacienteCreate(PacienteBase):
    pass

class PacienteResponse(PacienteBase):
    id_paciente: int
    criado_em: Optional[datetime] = None

    class Config:
        from_attributes = True

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

    class Config:
        from_attributes = True

class MarcarReposicaoRequest(BaseModel):
    reposto: bool = True
    observacoes_reposicao: Optional[str] = None

# ==========================================
# SCHEMAS DE AVALIAÇÃO CLÍNICA
# ==========================================

class AvaliacaoClinicaResumoSchema(BaseModel):
    id_avaliacao: Optional[int] = None
    pressao_arterial: Optional[str] = "N/A"
    frequencia_cardiaca: Optional[int] = None
    frequencia_respiratoria: Optional[int] = None
    saturacao_o2: Optional[int] = None
    glicemia: Optional[int] = None
    temperatura: Optional[float] = None
    escala_glasgow: Optional[int] = None
    abertura_ocular: Optional[int] = None
    resposta_verbal: Optional[int] = None
    resposta_motora: Optional[int] = None
    hemoglicoteste: Optional[int] = None
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

    class Config:
        from_attributes = True

# ==========================================
# SCHEMAS DE FICHA DE ATENDIMENTO
# ==========================================

class FichaAtendimentoCreate(BaseModel):
    uuid_offline: Optional[str] = None
    id_unidade: int
    id_responsavel: int
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

class FichaResumoResponse(BaseModel):
    id_ficha: int
    nome_paciente: str
    pressao_arterial: Optional[str] = "N/A"

    class Config:
        from_attributes = True

class FichaDetalhadaReposicaoResponse(BaseModel):
    """
    Estrutura consolidada para o Técnico de Enfermagem e Administrador:
    Agrupa Ficha de Atendimento + Avaliação Clínica do Paciente + Utensílios Gastos.
    """
    id_ficha: int
    uuid_offline: Optional[str] = None
    data_atendimento: Optional[datetime] = None
    placa_unidade: Optional[str] = None
    bairro: Optional[str] = None
    nome_paciente: Optional[str] = "Não informado"
    idade_paciente: Optional[int] = None
    sexo_paciente: Optional[str] = None
    avaliacao_clinica: Optional[AvaliacaoClinicaResumoSchema] = None
    utensilios_gastos: Optional[UtensiliosGastosSchema] = None

    class Config:
        from_attributes = True

# ==========================================
# SCHEMAS DE SINCRONIZAÇÃO OFFLINE (SYNC)
# ==========================================

class FichaSyncItem(BaseModel):
    uuid_offline: str
    id_unidade: int
    id_responsavel: int
    id_condutor: Optional[int] = None
    id_tecnico: Optional[int] = None
    id_medico: Optional[int] = None
    id_hospital: Optional[int] = None
    cep: Optional[str] = None
    logradouro: Optional[str] = None
    bairro: Optional[str] = None
    numero: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    hora_chamado: Optional[datetime] = None
    hora_saida_base: Optional[datetime] = None
    hora_chegada_local: Optional[datetime] = None
    hora_conclusao: Optional[datetime] = None
    observacoes_gerais: Optional[str] = None
    paciente: Optional[PacienteCreate] = None
    avaliacao_clinica: Optional[AvaliacaoClinicaResumoSchema] = None
    utensilios_gastos: Optional[UtensiliosGastosSchema] = None

class SyncLoteRequest(BaseModel):
    fichas: List[FichaSyncItem]

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
    tempo_medio_resposta_minutos: float
    total_unidades_ativas: int
    total_unidades_paradas: int
    atendimentos_por_unidade: Dict[str, int]
    distribuicao_faixa_etaria: Dict[str, int]
    locais_maior_ocorrencia: List[Dict[str, Any]]
    reposicao_utensilios: DashboardReposicaoResumoResponse

# ==========================================
# SCHEMAS DE LOG DE AUDITORIA (RNF05)
# ==========================================

class LogAuditoriaCreate(BaseModel):
    id_usuario: Optional[int] = None
    acao: str
    detalhes_metadados: Optional[str] = None
    ip_origem: Optional[str] = None

class LogAuditoriaResponse(BaseModel):
    id_log: int
    id_usuario: Optional[int] = None
    acao: str
    detalhes_metadados: Optional[str] = None
    ip_origem: Optional[str] = None
    data_hora: Optional[datetime] = None

    class Config:
        from_attributes = True
