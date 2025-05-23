{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_COLETA_IMG_URG\
-- PROP\'d3SITO: Monitora o tempo de realiza\'e7\'e3o de exames de imagem\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_COLETA_IMG_URG"  AS\
\
\
 SELECT DISTINCT \
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
ATEND.CD_ATENDIMENTO AS CODIGOATENDIMENTO,\
TO_CHAR(PED.HR_PEDIDO, 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,\
ATEND.CD_PACIENTE AS CODIGOPACIENTE,\
PAC.NM_PACIENTE AS NOMEPACIENTE,\
CONV.NM_CONVENIO AS DESCRICAOCONVENIO,\
ESP.DS_ESPECIALID AS DESCRICAOESPECIALIDADE,\
PREST.NM_PRESTADOR AS NOMESOLICITANTE,\
PED.CD_PED_RX AS CodigoPedidoImg,\
ITEM.CD_ITPED_RX AS CodigoItemPedidoImg,\
ITEM.CD_EXA_RX AS CODIGOITEM,\
EXA.DS_EXA_RX AS DESCRICAOITEM,\
cor.NM_COR as NOMECOR,\
ROUND((SYSDATE - PED.HR_PEDIDO) * 1440) AS VALOR\
FROM dbamv.ATENDIME ATEND \
LEFT JOIN dbamv.PACIENTE PAC ON ATEND.CD_PACIENTE=PAC.CD_PACIENTE\
LEFT JOIN dbamv.CONVENIO CONV ON ATEND.CD_CONVENIO=CONV.CD_CONVENIO\
LEFT JOIN dbamv.CON_PLA PLA ON ATEND.CD_CONVENIO=PLA.CD_CONVENIO AND ATEND.CD_CON_PLA=PLA.CD_CON_PLA\
LEFT JOIN dbamv.ESPECIALID ESP ON ESP.CD_ESPECIALID=ATEND.CD_ESPECIALID\
LEFT JOIN dbamv.PED_RX PED ON PED.CD_ATENDIMENTO=ATEND.CD_ATENDIMENTO\
LEFT JOIN dbamv.PRESTADOR PREST ON PREST.CD_PRESTADOR=PED.CD_PRESTADOR\
LEFT JOIN dbamv.ITPED_RX ITEM ON ITEM.CD_PED_RX=PED.CD_PED_RX\
LEFT JOIN dbamv.EXA_RX EXA ON EXA.CD_EXA_RX=ITEM.CD_EXA_RX\
LEFT JOIN dbamv.MODALIDADE_EXAME MODAL ON MODAL.CD_MODALIDADE_EXAME=EXA.CD_MODALIDADE_EXAME\
\
 -- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center \
LEFT JOIN dbamv.triagem_atendimento triag on atend.cd_atendimento = triag.cd_atendimento \
LEFT JOIN dbamv.SACR_CLASSIFICACAO_RISCO classif  on  classif.CD_TRIAGEM_ATENDIMENTO=triag.CD_TRIAGEM_ATENDIMENTO \
LEFT JOIN dbamv.SACR_COR_REFERENCIA cor on cor.CD_COR_REFERENCIA=classif.CD_COR_REFERENCIA\
-- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center \
WHERE ATEND.HR_ATENDIMENTO>=(sysdate - interval '10' hour)\
AND ATEND.DT_ALTA IS NULL\
AND ATEND.TP_ATENDIMENTO='U'\
AND ITEM.CD_ITPED_RX IS NOT NULL\
AND ITEM.CD_LAUDO IS NULL\
AND MODAL.DS_SIGLA_MODALIDADE<>'CR'\
AND ITEM.DT_SOLICITACAO_GUIA IS NULL\
order by DATAHORAINICIO;\
\
\
}