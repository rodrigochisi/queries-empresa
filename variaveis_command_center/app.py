import streamlit as st
import os
from datetime import datetime
import pandas as pd
import subprocess

base_dir = "variaveis_command_center/grupo_santa"
log_file = "variaveis_command_center/log_edicoes.csv"

st.title("📝 Editor de Scripts SQL - Grupo Santa")

def listar_arquivos_sql(pasta_base):
    arquivos = []
    for root, dirs, files in os.walk(pasta_base):
        for file in files:
            if file.endswith(".sql"):
                arquivos.append(os.path.join(root, file))
    return arquivos
1
arquivos_sql = listar_arquivos_sql(base_dir)
st.write("🔍 Arquivos encontrados:", arquivos_sql)
st.write("📂 Caminho absoluto atual:", os.getcwd())


if not arquivos_sql:
    st.warning("Nenhum arquivo SQL encontrado.")
    st.stop()

arquivo_escolhido = st.selectbox("Escolha o arquivo para editar:", arquivos_sql)

with open(arquivo_escolhido, "r", encoding="utf-8") as f:
    conteudo = f.read()

novo_conteudo = st.text_area("Edite o conteúdo abaixo:", value=conteudo, height=400)

nome_autor = st.text_input("Seu nome:")
descricao = st.text_input("Descrição da alteração:")

if st.button("💾 Salvar e registrar alteração"):
    st.write("🔍 Debug: Iniciando salvamento")
    st.write("Arquivo:", arquivo_escolhido)
    st.write("Autor:", nome_autor)
    st.write("Descrição:", descricao)

    if not nome_autor or not descricao:
        st.error("Por favor, preencha seu nome e a descrição da alteração.")
    else:
        with open(arquivo_escolhido, "w", encoding="utf-8") as f:
            f.write(novo_conteudo)

        novo_log = {
            "arquivo": arquivo_escolhido,
            "autor": nome_autor,
            "descricao": descricao,
            "data_hora": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        os.makedirs(os.path.dirname(log_file), exist_ok=True)

        if os.path.exists(log_file):
            df = pd.read_csv(log_file)
            df = pd.concat([df, pd.DataFrame([novo_log])], ignore_index=True)
        else:
            df = pd.DataFrame([novo_log])

        df.to_csv(log_file, index=False)
        st.success("Alteração salva com sucesso e registrada no log!")

        try:
            token = os.environ.get("GITHUB_TOKEN")
            if token:
                repo_url = f"https://{token}:x-oauth-basic@github.com/rodrigochisi/queries-empresa.git"
                subprocess.run(["git", "remote", "set-url", "origin", repo_url])

            subprocess.run(["git", "add", arquivo_escolhido, log_file])
            subprocess.run(["git", "commit", "-m", f"Alteração por {nome_autor}: {descricao}"])
            subprocess.run(["git", "push"])
            st.success("Alterações enviadas para o GitHub!")
        except Exception as e:
            st.warning(f"Erro ao enviar para o GitHub: {e}")
