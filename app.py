import streamlit as st
import os
import pandas as pd
from datetime import datetime
from git import Repo

# Diretório onde os arquivos estão
BASE_DIR = "grupo_santa"
LOG_FILE = "log.csv"
REPO_PATH = os.getcwd()

# Título da aplicação
st.title("Editor de Scripts SQL - Grupo Santa")

# Função para listar arquivos SQL recursivamente
def listar_arquivos_sql(base_path):
    arquivos = []
    for root, dirs, files in os.walk(base_path):
        for file in files:
            if file.endswith(".sql"):
                full_path = os.path.join(root, file)
                arquivos.append(full_path)
    return arquivos

# Selecionar arquivo
arquivos = listar_arquivos_sql(BASE_DIR)
arquivo_escolhido = st.selectbox("Escolha o arquivo para editar:", arquivos)

# Mostrar conteúdo
if arquivo_escolhido:
    with open(arquivo_escolhido, "r", encoding="utf-8") as f:
        conteudo = f.read()

    novo_conteudo = st.text_area("Conteúdo do arquivo:", conteudo, height=400)

    # Informações do log
    usuario = st.text_input("Seu nome")
    jira_id = st.text_input("ID da tarefa (JIRA-1234)")
    descricao = st.text_area("Descrição da alteração")

    if st.button("Salvar e Enviar para o Git"):
        if usuario and jira_id and descricao:
            # Salvar novo conteúdo
            with open(arquivo_escolhido, "w", encoding="utf-8") as f:
                f.write(novo_conteudo)

            # Gravar log
            data = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            log_data = pd.DataFrame([[data, usuario, arquivo_escolhido, jira_id, descricao]],
                                    columns=["data", "usuario", "arquivo", "jira_id", "descricao"])
            if os.path.exists(LOG_FILE):
                log_data.to_csv(LOG_FILE, mode='a', header=False, index=False)
            else:
                log_data.to_csv(LOG_FILE, index=False)

            # Git commit e push
            repo = Repo(REPO_PATH)
            repo.git.add(arquivo_escolhido)
            repo.git.add(LOG_FILE)
            commit_msg = f"{jira_id} - {descricao} ({usuario})"
            repo.index.commit(commit_msg)
            origin = repo.remote(name='origin')
            origin.push()

            st.success("Alterações salvas e enviadas com sucesso!")
        else:
            st.warning("Preencha todos os campos para salvar.")
