{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_PARECER_INT\
-- PROP\'d3SITO: Monitora o tempo de laudo de pareceres m\'e9dicos na interna\'e7\'e3o\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_PARECER_INT"  AS\
\
  select \
atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
atend.CD_PACIENTE as CODIGOPACIENTE,\
par.CD_ATENDIMENTO as CODIGOATENDIMENTO,\
TO_CHAR(par.DT_SOLICITACAO,'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
conv.NM_CONVENIO as DESCRICAOCONVENIO,\
pac.NM_PACIENTE as NOMEPACIENTE,\
espatend.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
unid.CD_SETOR as CODIGOSETOR ,\
setor.NM_SETOR as DESCRICAOSETOR ,\
leito.CD_UNID_INT as CODIGOUNIDADEINTERNACAO ,\
unid.DS_UNID_INT as DESCRICAOUNIDADEINTERNACAO ,\
leito.CD_LEITO as CODIGOLEITO ,\
leito.DS_LEITO as DESCRICAOLEITO,\
PAR.CD_PAR_MED AS CODIGOITEM,\
prestsolic.NM_PRESTADOR as NOMESOLICITANTE,\
case when prest.NM_PRESTADOR is null then esp.DS_ESPECIALID else esp.DS_ESPECIALID||' - '||prest.NM_PRESTADOR end AS DESCRICAOITEM,\
ROUND((SYSDATE - par.DT_SOLICITACAO) * 1440) as VALOR\
from DBAMV.PAR_MED PAR \
left join DBAMV.ATENDIME ATEND on atend.CD_ATENDIMENTO=par.CD_ATENDIMENTO\
left join DBAMV.PACIENTE PAC on pac.CD_PACIENTE=atend.CD_PACIENTE\
left join DBAMV.LEITO LEITO on leito.CD_LEITO=atend.CD_LEITO\
LEFT JOIN DBAMV.UNID_INT UNID ON UNID.CD_UNID_INT=LEITO.CD_UNID_INT\
LEFT JOIN DBAMV.SETOR SETOR ON SETOR.CD_SETOR=UNID.CD_SETOR\
left join DBAMV.ESPECIALID esp on esp.CD_ESPECIALID=par.CD_ESPECIALID\
left join dbamv.especialid espatend on espatend.CD_ESPECIALID=atend.CD_ESPECIALID\
left join DBAMV.CONVENIO conv on conv.CD_CONVENIO=atend.CD_CONVENIO\
left join DBAMV.PRESTADOR prest on par.CD_PRESTADOR_REQUISITADO=prest.CD_PRESTADOR\
left join DBAMV.PRESTADOR prestsolic on par.CD_PRESTADOR=prestsolic.CD_PRESTADOR\
where \
PAR.DT_CANCELAMENTO is null \
and PAR.DT_PARECER is null\
and ATEND.DT_ALTA is null \
and ATEND.TP_ATENDIMENTO='I'\
and PAR.DT_SOLICITACAO>=(sysdate - interval '7' day)\
order by DATAHORAINICIO;\
\
}