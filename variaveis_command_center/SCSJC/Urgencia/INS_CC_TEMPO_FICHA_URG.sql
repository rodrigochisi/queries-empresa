



BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_FICHA_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_FICHA_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Abertura de Ficha
-- PROPÓSITO: Monitora o tempo de espera do paciente para abrir ficha de atendimento
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_FICHA_URG"  AS
 
 select distinct
  triag.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
triag.CD_TRIAGEM_ATENDIMENTO AS CODIGOTRIAGEM,
TO_CHAR(triag.DH_PRE_ATENDIMENTO_FIM, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
triag.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(triag.NM_PACIENTE) AS NOMEPACIENTE,
fil.DS_FILA||' - '||triag.DS_SENHA AS DESCRICAOITEM,
round((SYSDATE - triag.DH_PRE_ATENDIMENTO_FIM) * 1440) as VALOR
from dbamv.triagem_atendimento triag
left join dbamv.fila_senha fil on fil.CD_FILA_SENHA=triag.CD_FILA_SENHA
where triag.DH_PRE_ATENDIMENTO_FIM is not null
and triag.CD_ATENDIMENTO is null
and triag.cd_multi_empresa  IN (1,7,9)
AND triag.cd_fila_senha in (1,2,11,12,13)
--and (fil.DS_FILA like '%TRIAGEM%' or ds_fila like '%SINTOMAS%')
and triag.DH_REMOVIDO is null
and triag.DH_PRE_ATENDIMENTO>=(sysdate - interval '2' hour)
and triag.CD_ATENDIMENTO is null
order by DATAHORAINICIO;
