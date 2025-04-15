{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_AUTORIZACAO_URG\
-- PROP\'d3SITO: Monitora o tempo de autoriza\'e7\'e3o da guia na urg\'eancia \
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_AUTORIZACAO_URG"  AS\
\
\
select distinct \
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,\
TO_CHAR(guia.DT_GERACAO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
atend.CD_PACIENTE AS CODIGOPACIENTE,\
pac.NM_PACIENTE AS NOMEPACIENTE,\
conv.NM_CONVENIO as DESCRICAOCONVENIO,\
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
prest.NM_PRESTADOR as NOMESOLICITANTE,\
guia.CD_GUIA as CODIGOGUIA,\
item.CD_IT_GUIA as CODIGOITEMGUIA,\
item.CD_PRO_FAT as CODIGOITEM,\
pro.DS_PRO_FAT as DESCRICAOITEM,\
round((SYSDATE - guia.DT_GERACAO) * 1440) as VALOR\
from dbamv.atendime atend \
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE\
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR\
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO\
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA\
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID\
left join dbamv.guia guia on guia.CD_ATENDIMENTO=atend.CD_ATENDIMENTO\
left join dbamv.it_GUIA item on item.CD_GUIA=guia.CD_GUIA\
left join dbamv.pro_fat pro on pro.CD_PRO_FAT=item.CD_PRO_FAT\
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)\
and atend.DT_ALTA is null\
and atend.TP_ATENDIMENTO='U'\
and guia.CD_GUIA is not null\
and guia.TP_SITUACAO='P'\
order by DATAHORAINICIO;\
}