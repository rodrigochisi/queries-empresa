import streamlit as st
import os

st.title("🧪 Teste rápido do Streamlit")

pasta = "variaveis_command_center/grupo_santa"

st.write("📁 Arquivos encontrados:")

if os.path.exists(pasta):
    for root, dirs, files in os.walk(pasta):
        for file in files:
            st.write(os.path.join(root, file))
else:
    st.error("❌ Diretório não encontrado!")
