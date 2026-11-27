# Autenticação, Segurança e LGPD

## Fluxo de Autenticação (`auth_controller.py` + `security_service.py`)

1. O usuário envia login e senha para `POST /api/auth/login` (protegido por **rate limit** via `slowapi`, padrão `10/minute` em produção).
2. `autenticar_usuario()` busca o usuário e compara a senha com **`bcrypt`** (`BCRYPT_ROUNDS = 12`).
   * **Proteção contra Timing Attack:** quando o login não existe, executa `verificar_senha(senha, HASH_DUMMY)` para manter o tempo de resposta constante.
   * **Troca obrigatória:** se `usuario.trocar_senha == True`, retorna HTTP `403` (`TROCA_SENHA_OBRIGATORIA`) até a troca da senha inicial.
3. Gera um **JWT (`HS256`)** contendo:
   * `sub` (`id_usuario`), `login`, `perfil`, `ver` (`token_version`), `jti` (identificador único do token) e `exp` (`JWT_EXPIRE_MINUTES = 1440`, equivalente a **24 horas**).

### Validação e Revogação (`Backend/dependencies.py`)
Em toda rota autenticada, `get_usuario_atual()` verifica em ordem:
1. Assinatura e expiração do JWT (`decodificar_token_acesso`).
2. Se o `jti` foi revogado no logout (tabela `TokenRevogado`).
3. Se o `ver` do token corresponde ao `token_version` atual do usuário (revoga todas as sessões se o admin desativar ou alterar o perfil).
4. Se `usuario.ativo == True` e `not usuario.trocar_senha`.

---

## Autorização (RBAC) e Proteção contra BOLA / IDOR

* **Controle por Perfil (`exigir_perfil`):** rotas administrativas e de IA exigem perfis específicos (ex.: `ADMINISTRADOR`), retornando `403 Forbidden` para perfis sem permissão. No Front-end, `onGenerateRoute` (`Frontend/lib/main.dart`) também bloqueia a navegação para `/dashboard` se o usuário não for `PerfilUsuario.admin`.
* **Controle por Dono do Registro (BOLA/IDOR) em `Backend/controllers/ficha_controller.py`:**
  * Na listagem (`/api/fichas/` e `/api/fichas/resumo`), `id_responsavel_filtro = None if usuario.perfil == "ADMINISTRADOR" else usuario.id_usuario`.
  * Nos detalhes por ID (`/api/fichas/detalhes/{id_ficha}`), perfis não-administradores recebem `403 Forbidden` caso `ficha_obj.id_responsavel != usuario.id_usuario`.

---

## Proteção de Dados Sensíveis (LGPD) e Hardening Web

* **Pseudonimização de CPF (`Backend/models/paciente.py`):** antes de persistir no banco, `pseudonimizar_cpf()` converte os dígitos do CPF em hash **HMAC-SHA256** (64 caracteres hexadecimais) usando `CPF_HMAC_KEY`. O banco permite busca por igualdade sem armazenar o CPF em texto claro.
* **Auditoria (`LogAuditoria`):** logins, falhas de autenticação, criação e visualização de fichas registram `acao`, `id_usuario`, `ip_origem` e timestamp.
* **Proteção contra SQL Injection:** todas as consultas usam SQLAlchemy ORM parametrizado.
* **Proteção contra XSS e Clickjacking (`docker/nginx.conf`):**
  * `Content-Security-Policy` restritivo (`default-src 'self'; object-src 'none'; frame-ancestors 'none'`)
  * `X-Content-Type-Options: nosniff`
  * `X-Frame-Options: DENY`
  * `Referrer-Policy: strict-origin-when-cross-origin`
  * `server_tokens off`
* **Mobile Android:** `android:allowBackup="false"` em `AndroidManifest.xml` e ofuscação R8 (`isMinifyEnabled = true`) em `build.gradle.kts`.
