

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_TRIAGEM_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_TRIAGEM_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Triagem
-- PROPÓSITO: Monitora o paciente aguardando triagem
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_TRIAGEM_URG"
 
 
 AS select CODIGOMULTIEMPRESA,
         CODIGOTRIAGEM,
         DATAHORAINICIO,
         CODIGOPACIENTE,
         NOMEPACIENTE,
         DESCRICAOITEM,
         VALOR
    FROM
    (
 
  select distinct
  triag.CD_MULTI_EMPRESA as CODIGOMULTIEMPRESA,
triag.CD_TRIAGEM_ATENDIMENTO AS CODIGOTRIAGEM,
TO_CHAR(triag.DH_PRE_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
triag.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(triag.NM_PACIENTE) AS NOMEPACIENTE,
fil.DS_FILA||' - '||triag.DS_SENHA AS DESCRICAOITEM,
round((SYSDATE - triag.DH_PRE_ATENDIMENTO) * 1440) as VALOR
from DBAMV.triagem_atendimento triag
left join DBAMV.fila_senha fil on fil.CD_FILA_SENHA=triag.CD_FILA_SENHA
where triag.DH_PRE_ATENDIMENTO_FIM is null
and triag.CD_ATENDIMENTO is null
and triag.CD_MULTI_EMPRESA = 1
AND triag.cd_fila_senha in (1,2,11,12,13)
--and fil.DS_FILA like '%TRIAGEM%'
and triag.DH_REMOVIDO is null
and triag.DH_PRE_ATENDIMENTO>=(sysdate - interval '4' hour)
and triag.CD_TRIAGEM_ATENDIMENTO not in (select sacrt.CD_TRIAGEM_ATENDIMENTO from sacr_tempo_processo_historico sacrt where sacrt.DH_PROCESSO>=(sysdate - interval '4' hour) and sacrt.CD_TRIAGEM_ATENDIMENTO is not null and sacrt.CD_TIPO_TEMPO_PROCESSO<>1)


union all



  select distinct
  triag.CD_MULTI_EMPRESA as CODIGOMULTIEMPRESA,
triag.CD_TRIAGEM_ATENDIMENTO AS CODIGOTRIAGEM,
TO_CHAR(triag.DH_PRE_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
triag.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(triag.NM_PACIENTE) AS NOMEPACIENTE,
fil.DS_FILA||' - '||triag.DS_SENHA AS DESCRICAOITEM,
round((SYSDATE - triag.DH_PRE_ATENDIMENTO) * 1440) as VALOR
from DBAMV.triagem_atendimento triag
left join DBAMV.fila_senha fil on fil.CD_FILA_SENHA=triag.CD_FILA_SENHA
where triag.DH_PRE_ATENDIMENTO_FIM is null
and triag.CD_ATENDIMENTO is null
and triag.CD_MULTI_EMPRESA  = 7
 -- AND triag.cd_fila_senha in (1,2,11,12,13)
--and fil.DS_FILA like '%TRIAGEM%'
and triag.DH_REMOVIDO is null
and triag.DH_PRE_ATENDIMENTO>=(sysdate - interval '4' hour)
and triag.CD_TRIAGEM_ATENDIMENTO not in (select sacrt.CD_TRIAGEM_ATENDIMENTO from sacr_tempo_processo_historico sacrt where sacrt.DH_PROCESSO>=(sysdate - interval '4' hour) and sacrt.CD_TRIAGEM_ATENDIMENTO is not null and sacrt.CD_TIPO_TEMPO_PROCESSO<>1)



union all


  select distinct
  triag.CD_MULTI_EMPRESA as CODIGOMULTIEMPRESA,
triag.CD_TRIAGEM_ATENDIMENTO AS CODIGOTRIAGEM,
TO_CHAR(triag.DH_PRE_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
triag.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(triag.NM_PACIENTE) AS NOMEPACIENTE,
fil.DS_FILA||' - '||triag.DS_SENHA AS DESCRICAOITEM,
round((SYSDATE - triag.DH_PRE_ATENDIMENTO) * 1440) as VALOR
from DBAMV.triagem_atendimento triag
left join DBAMV.fila_senha fil on fil.CD_FILA_SENHA=triag.CD_FILA_SENHA
where triag.DH_PRE_ATENDIMENTO_FIM is null
and triag.CD_ATENDIMENTO is null
and triag.CD_MULTI_EMPRESA = 9
AND triag.cd_fila_senha in   (53,54,55,56,57,69,71)
--and fil.DS_FILA like '%TRIAGEM%'
and triag.DH_REMOVIDO is null
and triag.DH_PRE_ATENDIMENTO>=(sysdate - interval '4' hour)
and triag.CD_TRIAGEM_ATENDIMENTO not in (select sacrt.CD_TRIAGEM_ATENDIMENTO from sacr_tempo_processo_historico sacrt where sacrt.DH_PROCESSO>=(sysdate - interval '4' hour) and sacrt.CD_TRIAGEM_ATENDIMENTO is not null and sacrt.CD_TIPO_TEMPO_PROCESSO<>1)
);
