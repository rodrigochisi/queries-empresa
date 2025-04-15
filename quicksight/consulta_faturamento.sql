/*
================================================================================
NOME: consulta_faturamento.sql
OBJETIVO: Consulta de faturamento mensal por convênio
AUTOR: Maria Oliveira
DATA CRIAÇÃO: 2025-03-10
================================================================================
HISTÓRICO DE ALTERAÇÕES:
- [2025-04-10] por Maria Oliveira - Inclusão de coluna de glosa (JIRA-1222)
================================================================================
*/

SELECT
    convenio,
    mes_referencia,
    valor_faturado,
    valor_glosa
FROM faturamento_mensal;
