

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_LAUDO_LAB_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_LAUDO_LAB_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Laudo de Exame Laboratorial
-- PROPÓSITO: Monitora o tempo de laudo de exames laboratoriais
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_LAUDO_LAB_URG"  AS
 
 
 SELECT DISTINCT
  ATEND.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,
ATEND.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(COALESCE((select logm.HR_MOVIMENTO  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO  like 'Amostra associada ao exame foi recepcionada/colhida pelo Laboratório%' and rownum=1),ped.HR_PED_LAB), 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,
ATEND.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(PAC.NM_PACIENTE) AS NOMEPACIENTE,
CONV.NM_CONVENIO AS DESCRICAOCONVENIO,
ESP.DS_ESPECIALID AS DESCRICAOESPECIALIDADE,
PREST.NM_PRESTADOR AS NOMESOLICITANTE,
PED.CD_PED_LAB AS CODIGOPEDIDOLAB,
ITEM.CD_ITPED_LAB AS CODIGOITEMPEDIDOLAB,
ITEM.CD_EXA_LAB AS CODIGOITEM,
EXA.NM_EXA_LAB AS DESCRICAOITEM,
ROUND((SYSDATE - COALESCE((select logm.HR_MOVIMENTO  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO  like 'Amostra associada ao exame foi recepcionada/colhida pelo Laboratório%' and rownum=1),ped.HR_PED_LAB)) * 1440) AS VALOR
FROM DBAMV.ATENDIME ATEND
LEFT JOIN DBAMV.PACIENTE PAC ON ATEND.CD_PACIENTE=PAC.CD_PACIENTE
LEFT JOIN DBAMV.CONVENIO CONV ON ATEND.CD_CONVENIO=CONV.CD_CONVENIO
LEFT JOIN DBAMV.CON_PLA PLA ON ATEND.CD_CONVENIO=PLA.CD_CONVENIO AND ATEND.CD_CON_PLA=PLA.CD_CON_PLA
LEFT JOIN DBAMV.ESPECIALID ESP ON ESP.CD_ESPECIALID=ATEND.CD_ESPECIALID
LEFT JOIN DBAMV.PED_LAB PED ON PED.CD_ATENDIMENTO=ATEND.CD_ATENDIMENTO
LEFT JOIN DBAMV.PRESTADOR PREST ON PREST.CD_PRESTADOR=PED.CD_PRESTADOR
LEFT JOIN DBAMV.ITPED_LAB ITEM ON ITEM.CD_PED_LAB=PED.CD_PED_LAB
LEFT JOIN DBAMV.EXA_LAB EXA ON EXA.CD_EXA_LAB=ITEM.CD_EXA_LAB
WHERE ATEND.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
AND ATEND.DT_ALTA IS NULL
AND ATEND.TP_ATENDIMENTO='U'
AND EXA.NM_EXA_LAB NOT LIKE '%UROCULTURA%'
AND ITEM.CD_ITPED_LAB IS NOT NULL
AND ((ATEND.CD_MULTI_EMPRESA = 11 AND CD_LABORATORIO = 24) OR (CD_LABORATORIO = 29))
and item.CD_EXA_LAB not in (2997)
and (item.SN_ASSINADO='N' or item.SN_ASSINADO is null)
and (item.SN_REALIZADO='S' or (select logm.HR_MOVIMENTO  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO  like 'Amostra associada ao exame foi recepcionada/colhida pelo Laboratório%' and rownum=1) is not null )
order by DATAHORAINICIO;
