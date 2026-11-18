"""
rotate_passwords.py — Rotação obrigatória de senhas comprometidas
=================================================================
CONTEXTO
--------
Os commits a4ae5d5 (brava.db na raiz) e f474336 (Backend/brava.db)
introduziram arquivos SQLite no histórico do repositório. Esses arquivos
contêm 4 registros na tabela `usuario` com hashes SHA-256 simples (sem sal,
64 caracteres hexadecimais), que são muito mais fáceis de reverter por
dicionário ou força bruta do que o algoritmo atual (PBKDF2-HMAC-SHA256,
600 000 iterações, sal aleatório de 16 bytes).

Este script lê as senhas novas das variáveis de ambiente abaixo, gera
hashes PBKDF2 seguros e os grava diretamente no banco PostgreSQL (ou SQLite)
apontado por DATABASE_URL. Ele também força `trocar_senha = TRUE` para todos
os usuários afetados, de modo que o sistema exija uma nova senha no próximo
login mesmo que alguém esteja com uma sessão ativa.

COMO USAR
---------
1. Defina as variáveis de ambiente com as novas senhas ANTES de rodar:

       # Linux / macOS
       export DATABASE_URL="postgresql+psycopg2://postgres:senha@localhost:5432/brava"
       export NEW_ADMIN_PASSWORD="SuaSenhaAdminForte2025!"
       export NEW_EQUIPE_PASSWORD="SuaSenhaEquipeForte2025!"

       # Windows PowerShell
       $env:DATABASE_URL = "postgresql+psycopg2://postgres:senha@localhost:5432/brava"
       $env:NEW_ADMIN_PASSWORD = "SuaSenhaAdminForte2025!"
       $env:NEW_EQUIPE_PASSWORD = "SuaSenhaEquipeForte2025!"

2. Execute a partir da pasta Backend/:

       python rotate_passwords.py

3. Confirme a saída: o script imprime cada login atualizado e o prefixo do
   novo hash para auditoria visual.

4. Avise o time: todas as sessões JWT existentes continuam válidas até
   expirar (padrão 24 h). Após a expiração, o login exigirá a nova senha.
   Reduza JWT_EXPIRE_MINUTES temporariamente se quiser invalidar mais rápido.

SENHAS COMPROMETIDAS (hashes SHA-256 puro expostos no histórico git)
--------------------------------------------------------------------
  admin     : hash 240be518fabd2724ddb6f04eeb1da5967448d786
  enfermeiro: hash 42c2a2c37dddcd761f98c38a35e5c71f0b6c0a89  (mesma senha dos três)
  tecnico   : hash 42c2a2c37dddcd761f98c38a35e5c71f0b6c0a89
  condutor  : hash 42c2a2c37dddcd761f98c38a35e5c71f0b6c0a89

  Commits: a4ae5d5 (brava.db), f474336 (Backend/brava.db)
  Autor:   Madu3304 <mdua0722@gmail.com>
  Data:    Set/2026

NOTA SOBRE O HISTÓRICO GIT
---------------------------
Este script resolve o risco *operacional* (senhas reutilizáveis em produção).
O histórico permanece intacto. Para apagar os blobs do histórico é necessário
`git filter-repo` + force-push coordenado em todas as branches — decisão do time.
"""

import hashlib
import os
import secrets
import sys
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

# =============================================================================
# Configuração
# =============================================================================

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("[ERRO] DATABASE_URL não definida. Configure a variável de ambiente antes de rodar.")
    sys.exit(1)

NEW_ADMIN_PASSWORD = os.getenv("NEW_ADMIN_PASSWORD", "").strip()
NEW_EQUIPE_PASSWORD = os.getenv("NEW_EQUIPE_PASSWORD", "").strip()

if not NEW_ADMIN_PASSWORD or not NEW_EQUIPE_PASSWORD:
    print("[ERRO] NEW_ADMIN_PASSWORD e NEW_EQUIPE_PASSWORD devem estar definidas.")
    print("       Exemplo:")
    print('         export NEW_ADMIN_PASSWORD="SuaSenhaAdminForte2025!"')
    print('         export NEW_EQUIPE_PASSWORD="SuaSenhaEquipeForte2025!"')
    sys.exit(1)

if len(NEW_ADMIN_PASSWORD) < 12 or len(NEW_EQUIPE_PASSWORD) < 12:
    print("[ERRO] As novas senhas devem ter no mínimo 12 caracteres.")
    sys.exit(1)

# =============================================================================
# Hashing PBKDF2
# =============================================================================

PBKDF2_ITERATIONS = 600_000


def gerar_hash_pbkdf2(senha: str) -> str:
    """Gera hash PBKDF2-HMAC-SHA256 idêntico ao produzido por security_service.py."""
    salt = secrets.token_hex(16)
    derivado = hashlib.pbkdf2_hmac(
        "sha256",
        senha.encode("utf-8"),
        bytes.fromhex(salt),
        PBKDF2_ITERATIONS,
    ).hex()
    sep = "$"
    return f"pbkdf2_sha256{sep}{PBKDF2_ITERATIONS}{sep}{salt}{sep}{derivado}"


# =============================================================================
# Mapeamento login → nova senha
# =============================================================================

USUARIOS_AFETADOS = {
    # perfil ADMINISTRADOR — hash SHA-256 puro 240be518... exposto no commit a4ae5d5
    "admin": NEW_ADMIN_PASSWORD,
    # perfis de campo — hash SHA-256 puro 42c2a2c3... exposto nos mesmos commits
    "enfermeiro": NEW_EQUIPE_PASSWORD,
    "tecnico": NEW_EQUIPE_PASSWORD,
    "condutor": NEW_EQUIPE_PASSWORD,
}

# =============================================================================
# Execução
# =============================================================================


def main() -> None:
    connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
    engine = create_engine(DATABASE_URL, connect_args=connect_args, echo=False)

    print(f"\n[rotate_passwords] Conectando em: {DATABASE_URL.split('@')[-1]}")
    print(f"[rotate_passwords] Iterações PBKDF2: {PBKDF2_ITERATIONS:,}")
    print(f"[rotate_passwords] Usuários a rotacionar: {list(USUARIOS_AFETADOS.keys())}\n")

    atualizados = 0
    nao_encontrados = []

    with engine.begin() as conn:
        for login, nova_senha in USUARIOS_AFETADOS.items():
            novo_hash = gerar_hash_pbkdf2(nova_senha)

            resultado = conn.execute(
                text(
                    "UPDATE usuario "
                    "SET senha_hash = :hash, trocar_senha = TRUE "
                    "WHERE login = :login"
                ),
                {"hash": novo_hash, "login": login},
            )

            if resultado.rowcount == 0:
                nao_encontrados.append(login)
                print(f"  [AVISO] Usuário '{login}' não encontrado no banco — pulado.")
            else:
                # Imprime apenas os primeiros 30 chars do hash para auditoria visual (nunca o hash completo em log)
                print(
                    f"  [OK] login='{login}' — novo hash={novo_hash[:30]}...  trocar_senha=TRUE"
                )
                atualizados += 1

    print(f"\n[rotate_passwords] Concluído. {atualizados} usuário(s) atualizados.")
    if nao_encontrados:
        print(
            f"[rotate_passwords] AVISO: {len(nao_encontrados)} usuário(s) não encontrados no banco: "
            f"{nao_encontrados}"
        )
    print(
        "[rotate_passwords] Todos os usuários atualizados foram marcados com trocar_senha=TRUE.\n"
        "                   Na próxima sessão o sistema exigirá a troca de senha.\n"
    )


if __name__ == "__main__":
    main()
