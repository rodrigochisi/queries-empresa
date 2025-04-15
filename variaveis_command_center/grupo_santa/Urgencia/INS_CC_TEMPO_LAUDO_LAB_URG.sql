{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_LAUDO_LAB_URG\
-- PROP\'d3SITO: Monitora o tempo de laudo de exames laboratoriais\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_LAUDO_LAB_URG"  AS\
\
  SELECT DISTINCT \
\
  ATEND.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,\
ATEND.CD_ATENDIMENTO AS CODIGOATENDIMENTO,\
TO_CHAR(COALESCE((select logm.HR_MOVIMENTO  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO  like 'Exame Solicitado%' and rownum=1),ped.HR_PED_LAB), 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,\
ATEND.CD_PACIENTE AS CODIGOPACIENTE,\
PAC.NM_PACIENTE AS NOMEPACIENTE,\
CONV.NM_CONVENIO AS DESCRICAOCONVENIO,\
ESP.DS_ESPECIALID AS DESCRICAOESPECIALIDADE,\
PREST.NM_PRESTADOR AS NOMESOLICITANTE,\
PED.CD_PED_LAB AS CODIGOPEDIDOLAB,\
ITEM.CD_ITPED_LAB AS CODIGOITEMPEDIDOLAB,\
ITEM.CD_EXA_LAB AS CODIGOITEM,\
EXA.NM_EXA_LAB ||  \
CASE \
  WHEN (select logm.HR_MOVIMENTO  \
        from log_movimento_exame logm \
        where logm.CD_ITPED_LAB_RX = ITEM.CD_ITPED_LAB \
          and logm.CD_EXA_LAB = ITEM.CD_EXA_LAB \
          and logm.DS_MOVIMENTO like 'Amostra associada ao exame foi colhida no Setor.%') IS NOT NULL \
  THEN '  | LAUDADO - LAUDO :' || \
       TO_CHAR((select logm.HR_MOVIMENTO  \
                from log_movimento_exame logm \
                where logm.CD_ITPED_LAB_RX = ITEM.CD_ITPED_LAB \
                  and logm.CD_EXA_LAB = ITEM.CD_EXA_LAB \
                  and logm.DS_MOVIMENTO like 'Amostra associada ao exame foi colhida no Setor.%'), \
                'DD-MM-YYYY HH24:MI:SS')\
  ELSE ' '  \
END AS DESCRICAOITEM ,\
ROUND((SYSDATE - COALESCE((select logm.HR_MOVIMENTO  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO  like 'Exame Solicitado%' and rownum=1),ped.HR_PED_LAB)) * 1440) AS VALOR\
FROM DBAMV.ATENDIME ATEND \
LEFT JOIN DBAMV.PACIENTE PAC ON ATEND.CD_PACIENTE=PAC.CD_PACIENTE\
LEFT JOIN DBAMV.CONVENIO CONV ON ATEND.CD_CONVENIO=CONV.CD_CONVENIO\
LEFT JOIN DBAMV.CON_PLA PLA ON ATEND.CD_CONVENIO=PLA.CD_CONVENIO AND ATEND.CD_CON_PLA=PLA.CD_CON_PLA\
LEFT JOIN DBAMV.ESPECIALID ESP ON ESP.CD_ESPECIALID=ATEND.CD_ESPECIALID\
LEFT JOIN DBAMV.PED_LAB PED ON PED.CD_ATENDIMENTO=ATEND.CD_ATENDIMENTO\
LEFT JOIN DBAMV.PRESTADOR PREST ON PREST.CD_PRESTADOR=PED.CD_PRESTADOR\
LEFT JOIN DBAMV.ITPED_LAB ITEM ON ITEM.CD_PED_LAB=PED.CD_PED_LAB\
LEFT JOIN DBAMV.EXA_LAB EXA ON EXA.CD_EXA_LAB=ITEM.CD_EXA_LAB\
WHERE ATEND.HR_ATENDIMENTO>=(sysdate - interval '10' hour)\
AND ATEND.DT_ALTA IS NULL\
AND ATEND.TP_ATENDIMENTO='U'\
AND EXA.NM_EXA_LAB NOT LIKE '%UROCULTURA%'\
AND ITEM.CD_ITPED_LAB IS NOT NULL\
 AND ((ATEND.CD_MULTI_EMPRESA = 11 AND CD_LABORATORIO = 24) OR (ATEND.CD_MULTI_EMPRESA = 1  AND CD_LABORATORIO = 24))\
and item.CD_EXA_LAB not in (2997)\
and (item.SN_ASSINADO='N' or item.SN_ASSINADO is null)\
and (item.SN_REALIZADO='S' or (select logm.HR_MOVIMENTO  \
  from  log_movimento_exame logm where logm.CD_ITPED_LAB_RX=ITEM.CD_ITPED_LAB and logm.CD_EXA_LAB=item.CD_EXA_LAB and logm.DS_MOVIMENTO \
     like 'Exame Solicitado%' and rownum=1) is not null )\
order by DATAHORAINICIO;\
\
}