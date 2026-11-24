import pytest
from datetime import datetime, timezone, timedelta
from pydantic import ValidationError
from schemas import FichaAtendimentoCreate, AvaliacaoClinicaResumoSchema, PacienteCreate
from services.validation_service import validar_regras_clinicas_ficha

def test_validacao_fr_fora_do_padrao():
    """Testa B26: FR fora da faixa fisiológica válida (5 a 60 rpm)."""
    with pytest.raises(ValidationError) as exc:
        AvaliacaoClinicaResumoSchema(
            frequencia_respiratoria=2 # Abaixo do mínimo de 5 rpm
        )
    assert "frequencia_respiratoria" in str(exc.value)

def test_validacao_temperatura_fora_do_padrao():
    """Testa B26: Temperatura corporal fora de 25.0 a 45.0 °C."""
    with pytest.raises(ValidationError) as exc:
        AvaliacaoClinicaResumoSchema(
            temperatura=47.5 # Acima do máximo de 45 °C
        )
    assert "temperatura" in str(exc.value)

def test_validacao_glicemia_fora_do_padrao():
    """Testa B26: Glicemia capilar fora de 10 a 800 mg/dL."""
    with pytest.raises(ValidationError) as exc:
        AvaliacaoClinicaResumoSchema(
            glicemia=950 # Acima do máximo de 800 mg/dL
        )
    assert "glicemia" in str(exc.value)

def test_inconsistencia_soma_glasgow():
    """Testa B26: Soma de AO + RV + RM não confere com total informado."""
    with pytest.raises(ValidationError) as exc:
        AvaliacaoClinicaResumoSchema(
            abertura_ocular=4,
            resposta_verbal=5,
            resposta_motora=6,
            escala_glasgow=12 # Soma real é 15
        )
    assert "Glasgow" in str(exc.value)

def test_inconsistencia_cronologica_horarios(seed_dados_basicos):
    """Testa B26: Chegada ao local anterior ao horário do chamado."""
    agora = datetime.now(timezone.utc)
    with pytest.raises(ValidationError) as exc:
        FichaAtendimentoCreate(
            id_unidade=seed_dados_basicos["unidade"].id_unidade,
            id_medico=seed_dados_basicos["medico"].id_medico,
            hora_chamado=agora,
            hora_chegada_local=agora - timedelta(minutes=15) # Chegada antes do chamado
        )
    assert "hora de chegada ao local não pode ser anterior à hora do chamado" in str(exc.value)

def test_validacao_cpf_invalido():
    """Testa B24: Rejeição de CPF com dígitos verificadores incorretos."""
    with pytest.raises(ValidationError) as exc:
        PacienteCreate(
            nome="Paciente Teste",
            documento="111.222.333-99" # CPF com dígito inválido
        )
    assert "inválido" in str(exc.value).lower()

def test_validacao_regras_clinicas_sucesso(seed_dados_basicos):
    """Testa validação bem-sucedida de ficha com dados clínicos coerentes."""
    agora = datetime.now(timezone.utc)
    dados = FichaAtendimentoCreate(
        id_unidade=seed_dados_basicos["unidade"].id_unidade,
        id_medico=seed_dados_basicos["medico"].id_medico,
        hora_chamado=agora,
        hora_chegada_local=agora + timedelta(minutes=10),
        avaliacao_clinica=AvaliacaoClinicaResumoSchema(
            pressao_arterial="120/80",
            frequencia_cardiaca=75,
            frequencia_respiratoria=18,
            temperatura=36.5,
            glicemia=100,
            abertura_ocular=4,
            resposta_verbal=5,
            resposta_motora=6,
            escala_glasgow=15,
        )
    )
    valido, erros = validar_regras_clinicas_ficha(dados)
    assert valido
    assert len(erros) == 0
