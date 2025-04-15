/*
================================================================================
NOME: view_eventos.sql
OBJETIVO: Retorna eventos clínicos ativos dos pacientes
AUTOR: João da Silva
DATA CRIAÇÃO: 2025-04-01
================================================================================
HISTÓRICO DE ALTERAÇÕES:
- [2025-04-15] por João da Silva - Ajuste para considerar pacientes ativos (JIRA-1234)
================================================================================
*/

CREATE OR REPLACE VIEW view_eventos AS
SELECT
    e.id_evento,
    e.descricao,
    p.nome_paciente
FROM eventos e
JOIN pacientes p ON p.id_paciente = e.id_paciente
WHERE p.ativo = 'S';
