# Repositório de Queries e Views da Empresa

Este repositório centraliza todas as queries SQL versionadas da equipe de BI.

## 📁 Organização

- `mv/`: Views relacionadas ao sistema MV
- `quicksight/`: Consultas utilizadas em relatórios Quicksight
- `templates/`: Modelos de arquivos SQL com cabeçalho padronizado
- `variaveis_command_center/`: views utilizadas no App-  Command Center 

## 🧩 Boas práticas

- Sempre use o modelo de cabeçalho padronizado.
- Cada alteração deve ser registrada no histórico com data, nome e ticket Jira.
- As alterações devem ser feitas em branches nomeadas com o número do ticket (ex: `JIRA-1234-ajuste-view-eventos`)
- As mensagens de commit devem seguir o padrão:  
  `JIRA-1234 Breve descrição da alteração`

## ✅ Exemplo de commit

```bash
git checkout -b JIRA-1234-ajuste-view-eventos
git add mv/view_eventos.sql
git commit -m "JIRA-1234 Ajuste para considerar pacientes ativos"
git push origin JIRA-1234-ajuste-view-eventos
```
