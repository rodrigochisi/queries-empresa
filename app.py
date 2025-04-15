{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 import streamlit as st\
import os\
import pandas as pd\
from datetime import datetime\
from git import Repo\
\
# Diret\'f3rio onde os arquivos est\'e3o\
BASE_DIR = "grupo_santa"\
LOG_FILE = "log.csv"\
REPO_PATH = os.getcwd()\
\
# T\'edtulo da aplica\'e7\'e3o\
st.title("Editor de Scripts SQL - Grupo Santa")\
\
# Fun\'e7\'e3o para listar arquivos SQL recursivamente\
def listar_arquivos_sql(base_path):\
    arquivos = []\
    for root, dirs, files in os.walk(base_path):\
        for file in files:\
            if file.endswith(".sql"):\
                full_path = os.path.join(root, file)\
                arquivos.append(full_path)\
    return arquivos\
\
# Selecionar arquivo\
arquivos = listar_arquivos_sql(BASE_DIR)\
arquivo_escolhido = st.selectbox("Escolha o arquivo para editar:", arquivos)\
\
# Mostrar conte\'fado\
if arquivo_escolhido:\
    with open(arquivo_escolhido, "r", encoding="utf-8") as f:\
        conteudo = f.read()\
\
    novo_conteudo = st.text_area("Conte\'fado do arquivo:", conteudo, height=400)\
\
    # Informa\'e7\'f5es do log\
    usuario = st.text_input("Seu nome")\
    jira_id = st.text_input("ID da tarefa (JIRA-1234)")\
    descricao = st.text_area("Descri\'e7\'e3o da altera\'e7\'e3o")\
\
    if st.button("Salvar e Enviar para o Git"):\
        if usuario and jira_id and descricao:\
            # Salvar novo conte\'fado\
            with open(arquivo_escolhido, "w", encoding="utf-8") as f:\
                f.write(novo_conteudo)\
\
            # Gravar log\
            data = datetime.now().strftime("%Y-%m-%d %H:%M:%S")\
            log_data = pd.DataFrame([[data, usuario, arquivo_escolhido, jira_id, descricao]],\
                                    columns=["data", "usuario", "arquivo", "jira_id", "descricao"])\
            if os.path.exists(LOG_FILE):\
                log_data.to_csv(LOG_FILE, mode='a', header=False, index=False)\
            else:\
                log_data.to_csv(LOG_FILE, index=False)\
\
            # Git commit e push\
            repo = Repo(REPO_PATH)\
            repo.git.add(arquivo_escolhido)\
            repo.git.add(LOG_FILE)\
            commit_msg = f"\{jira_id\} - \{descricao\} (\{usuario\})"\
            repo.index.commit(commit_msg)\
            origin = repo.remote(name='origin')\
            origin.push()\
\
            st.success("Altera\'e7\'f5es salvas e enviadas com sucesso!")\
        else:\
            st.warning("Preencha todos os campos para salvar.")\
}