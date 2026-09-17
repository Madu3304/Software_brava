DROP TABLE IF EXISTS usuario CASCADE;

-- 1. Criar uma tabela simples
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nomeUsuario VARCHAR(400) NOT NULL,
	senhaUsuario VARCHAR(200) NOT NULL, 
    tokenUsuario VARCHAR(2048) NOT NULL,
    cookieUsuario VARCHAR(255) NOT NULL,
    perfilUsuario VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuario (
    nomeUsuario, 
    senhaUsuario, 
    tokenUsuario, 
    cookieUsuario, 
    perfilUsuario
) 
VALUES (
    'Desenvolvedor', 
    'senha_hash_aqui', 
    'token_exemplo_aqui', 
    'session_cookie_aqui', 
    'admin'
);

-- 3. Consultar os dados
SELECT * FROM usuario;

COMMIT;
