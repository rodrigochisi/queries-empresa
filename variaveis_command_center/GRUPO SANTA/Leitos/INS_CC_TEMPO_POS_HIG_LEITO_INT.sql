{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_POS_HIG_LEITO_INT\
-- PROP\'d3SITO: Monitora o tempo de p\'f3s  higieniza\'e7\'e3o do leito\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_POS_HIG_LEITO_INT"  AS\
\
\
  select \
setor.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
TO_CHAR(LIMPEZA.DT_HR_FIM_HIGIENIZA, 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,\
unid.CD_SETOR as CODIGOSETOR ,\
setor.NM_SETOR as DESCRICAOSETOR ,\
leito.CD_UNID_INT as CODIGOUNIDADEINTERNACAO ,\
unid.DS_UNID_INT as DESCRICAOUNIDADEINTERNACAO ,\
leito.CD_LEITO as CODIGOLEITO ,\
leito.DS_LEITO as DESCRICAOLEITO,\
LIMPEZA.CD_SOLIC_LIMPEZA as CODIGOITEM,\
LIMPEZA.NM_USUARIO AS NOMESOLICITANTE,\
ROUND((SYSDATE - LIMPEZA.DT_HR_FIM_HIGIENIZA) * 1440) AS VALOR\
from DBAMV.LEITO LEITO\
LEFT JOIN DBAMV.UNID_INT UNID ON UNID.CD_UNID_INT=LEITO.CD_UNID_INT\
LEFT JOIN DBAMV.SETOR SETOR ON SETOR.CD_SETOR=UNID.CD_SETOR\
LEFT JOIN DBAMV.SOLIC_LIMPEZA LIMPEZA ON LIMPEZA.CD_LEITO=LEITO.CD_LEITO and LIMPEZA.SN_REALIZADO='N' and LIMPEZA.TP_SITUACAO<>'C'\
where LEITO.TP_SITUACAO='A' \
and LEITO.TP_OCUPACAO='L' \
and LEITO.SN_EXTRA='N'\
and DT_HR_FIM_HIGIENIZA is not null\
order by DATAHORAINICIO;\
\
\
\
\
\
\
\
\
\
\
}