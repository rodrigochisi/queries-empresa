{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_INTERNACAO_URG\
-- PROP\'d3SITO: Monitora pacientes na urg\'eancia aguardando interna\'e7\'e3o \
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_INTERNACAO_URG"  AS\
\
\
\
  SELECT DISTINCT\
  ATEND.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
ATEND.CD_ATENDIMENTO as CODIGOATENDIMENTO, \
TO_CHAR(DOC.DH_CRIACAO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
ATEND.CD_PACIENTE AS CODIGOPACIENTE,\
PAC.NM_PACIENTE as NOMEPACIENTE,\
CONV.NM_CONVENIO AS DESCRICAOCONVENIO,\
atend.CD_ORI_ATE as CODIGOITEM,\
ori.DS_ORI_ATE as DESCRICAOITEM,\
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
prest.NM_PRESTADOR as NOMESOLICITANTE,\
round((SYSDATE - DOC.DH_CRIACAO) * 1440) as VALOR\
FROM dbamv.ATENDIME ATEND\
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE\
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE\
LEFT JOIN dbamv.CONVENIO CONV ON ATEND.CD_CONVENIO=CONV.CD_CONVENIO\
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID\
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA\
LEFT JOIN dbamv.PW_DOCUMENTO_CLINICO DOC ON DOC.CD_ATENDIMENTO = ATEND.CD_ATENDIMENTO\
left join dbamv.prestador prest on prest.CD_PRESTADOR=doc.CD_PRESTADOR\
LEFT JOIN dbamv.PW_DOCUMENTO_OBJETO OBJ ON  OBJ.CD_OBJETO = DOC.CD_OBJETO\
WHERE ATEND.TP_ATENDIMENTO = 'U'\
AND DOC.NM_DOCUMENTO = 'PEDIDO_INTERNACAO'\
AND ATEND.DT_ALTA IS NULL\
AND HR_ATENDIMENTO>=(sysdate - interval '10' hour)\
order by DATAHORAINICIO;\
\
\
}