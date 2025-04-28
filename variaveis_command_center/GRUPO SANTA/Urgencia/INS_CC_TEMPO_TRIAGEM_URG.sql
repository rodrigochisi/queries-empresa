{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww14120\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_TRIAGEM_URG\
-- PROP\'d3SITO: Monitora o paciente aguardando triagem\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_TRIAGEM_URG"  AS\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 \
\
\
\
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_TRIAGEM_URG" ("CODIGOMULTIEMPRESA", "CODIGOTRIAGEM", "DATAHORAINICIO", "CODIGOPACIENTE", "NOMEPACIENTE", "DESCRICAOITEM", "VALOR") AS \
  select distinct\
  triag.CD_MULTI_EMPRESA as CODIGOMULTIEMPRESA,\
triag.CD_TRIAGEM_ATENDIMENTO AS CODIGOTRIAGEM,\
TO_CHAR(triag.DH_PRE_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
triag.CD_PACIENTE AS CODIGOPACIENTE,\
triag.NM_PACIENTE AS NOMEPACIENTE,\
fil.DS_FILA||' - '||triag.DS_SENHA AS DESCRICAOITEM,\
round((SYSDATE - triag.DH_PRE_ATENDIMENTO) * 1440) as VALOR\
from DBAMV.triagem_atendimento triag \
left join DBAMV.fila_senha fil on fil.CD_FILA_SENHA=triag.CD_FILA_SENHA\
where triag.DH_PRE_ATENDIMENTO_FIM is null \
and triag.CD_ATENDIMENTO is null\
and fil.DS_FILA like '%TRIAGEM%'\
and triag.DH_REMOVIDO is null \
and triag.DH_PRE_ATENDIMENTO>=(sysdate - interval '4' hour)\
and triag.CD_TRIAGEM_ATENDIMENTO not in (select sacrt.CD_TRIAGEM_ATENDIMENTO from sacr_tempo_processo_historico sacrt where sacrt.DH_PROCESSO>=(sysdate - interval '4' hour) and sacrt.CD_TRIAGEM_ATENDIMENTO is not null and sacrt.CD_TIPO_TEMPO_PROCESSO<>1)\
order by DATAHORAINICIO;\
\
}