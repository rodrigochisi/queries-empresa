import streamlit as st
import os
from datetime import datetime
import pandas as pd
import subprocess

# Caminho base para buscar os .sql
base_dir = "grupo_santa"
log_file = "log_edicoes.csv"

st.title("📝 Editor de Scripts SQL - Grupo Santa")

# Função para encontrar todos os arquivos .sql
def listar_arquivos_sql(pasta_base):
    arquivos = []
    for root, dirs, files in os.walk(pasta_base):
        for file in files:
            if file.endswith(".sql"):
                arquivos.append(os.path.join(root, file))
    return arquivos

# Carregar lista de arquivos
arquivos_sql = listar_arquivos_sql(base_dir)

if not arquivos_sql:
    st.warning("Nenhum arquivo SQL encontrado em 'grupo_santa'.")
    st.stop()

# Dropdown para selecionar arquivo
arquivo_escolhido = st.selectbox("Escolha o arquivo para editar:", arquivos_sql)

# Ler conteúdo do arquivo
with open(arquivo_escolhido, "r", encoding="utf-8") as f:
    conteudo = f.read()

# Editor de texto
novo_conteudo = st.text_area("Edite o conteúdo abaixo:", value=conteudo, height=400)

# Nome e descrição para log
nome_autor = st.text_input("Seu nome:")
descricao = st.text_input("Descrição da alteração:")

# Botão de salvar
if st.button("💾 Salvar e registrar alteração"):
    if not nome_autor or not descricao:
        st.error("Por favor, preencha seu nome e a descrição da alteração.")
    else:
        # Salvar novo conteúdo no arquivo
        with open(arquivo_escolhido, "w", encoding="utf-8") as f:
            f.write(novo_conteudo)

        # Criar/atualizar CSV de log
        novo_log = {
            "arquivo": arquivo_escolhido,
            "autor": nome_autor,
            "descricao": descricao,
            "data_hora": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        if os.path.exists(log_file):
            df = pd.read_csv(log_file)
            df = pd.concat([df, pd.DataFrame([novo_log])], ignore_index=True)
        else:
            df = pd.DataFrame([novo_log])

        df.to_csv(log_file, index=False)
        st.success("Alteração salva com sucesso e registrada no log!")

        # Git commit e push (se configurado)
        try:
            subprocess.run(["git", "add", arquivo_escolhido, log_file])
            subprocess.run(["git", "commit", "-m", f"Alteração por {nome_autor}: {descricao}"])
            subprocess.run(["git", "push"])
            st.success("Alterações enviadas para o GitHub!")
        except Exception as e:
            st.warning(f"Erro ao enviar para o GitHub: {e}")
