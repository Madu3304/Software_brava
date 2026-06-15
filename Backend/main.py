import psycopg2

# 1. Definindo os dados de conexão (os mesmos do DBeaver)
dados_conexao = {
    "host": "localhost",
    "database": "Brava",  
    "user": "postgres",
    "password": "Bolo$369", 
    "port": "5432"
}

try:
    # 2. Estabelecendo a conexão
    print("Conectando ao banco de dados...")
    conexao = psycopg2.connect(**dados_conexao)
    
    # O cursor é o objeto que executa os comandos SQL no banco
    cursor = conexao.cursor()
    
    # 3. Criando uma tabela de exemplo
    print("Criando tabela...")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id SERIAL PRIMARY KEY,
            nomeUsuario VARCHAR(255) NOT NULL,
            senhaUsuário VARCHAR(255) NOT NULL,
            tokenUsuário TEXT NOT NULL,
            cookeiUsuario VARCHAR(255),
        );
    """)
    conexao.commit() # Salva a alteração no banco
    
    # 4. Inserindo dados (Comando INSERT)
    print("Inserindo um usuário de teste...")
    # Usamos %s por segurança contra SQL Injection
    comando_insert = "INSERT INTO usuarios (nome, email) VALUES (%s, %s) ON CONFLICT DO NOTHING;"
    cursor.execute(comando_insert, ("Ada Lovelace", "ada@email.com"))
    conexao.commit()

    # 5. Buscando dados (Comando SELECT)
    print("Buscando dados...")
    cursor.execute("SELECT id, nome, email FROM usuarios;")
    
    # fetchall() traz todas as linhas retornadas pela consulta
    linhas = cursor.fetchall()
    
    print("\n--- Usuários Cadastrados ---")
    for linha in linhas:
        print(f"ID: {linha[0]} | Nome: {linha[1]} | Email: {linha[2]}")
    print("----------------------------\n")

except Exception as erro:
    print(f"Erro ao operar no banco de dados: {erro}")

finally:
    # 6. Sempre feche o cursor e a conexão ao terminar
    if 'cursor' in locals():
        cursor.close()
    if 'conexao' in locals():
        conexao.close()
        print("Conexão com o banco encerrada.")