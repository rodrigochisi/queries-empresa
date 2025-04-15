{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww14240\viewh12300\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_MON_ALTA_MED_HOSP\
-- PROP\'d3SITO: Monitora alta hospitalar de pacientes com alta m\'e9dica\
-- CRIADO POR: Rodrigo\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025 por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_MON_ALTA_MED_HOSP"  AS\
 \
 with Tbl_Mon_Alta_Hosp As ( \
  select distinct \
  atend.HR_ALTA_MEDICA,\
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,\
TO_CHAR(atend.HR_ALTA_MEDICA, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
atend.CD_PACIENTE AS CODIGOPACIENTE,\
pac.NM_PACIENTE AS NOMEPACIENTE,\
conv.NM_CONVENIO as DESCRICAOCONVENIO,\
atend.CD_ORI_ATE as CODIGOITEM,\
ori.DS_ORI_ATE as DESCRICAOITEM,\
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
prest.NM_PRESTADOR as NOMESOLICITANTE,\
round((SYSDATE - atend.HR_ALTA_MEDICA) * 1440) as VALOR\
\
from dbamv.atendime atend \
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE\
left join dbamv.setor setor on setor.CD_SETOR=ori.CD_SETOR\
left join dbamv.sacr_tempo_processo_historico hist on hist.CD_ATENDIMENTO=atend.CD_ATENDIMENTO\
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE\
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR\
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO\
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA\
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID\
\
Where ( (atend.HR_ALTA_MEDICA BETWEEN SYSDATE - INTERVAL '24' HOUR AND SYSDATE + INTERVAL '24' HOUR)\
        OR (atend.DT_ALTA_MEDICA BETWEEN SYSDATE - INTERVAL '24' HOUR AND SYSDATE + INTERVAL '24' HOUR)\
       )  \
and atend.HR_ALTA_MEDICA is not null        \
and atend.DT_ALTA is null        \
\
\
)\
\
select  Mah.CODIGOMULTIEMPRESA,\
        Mah.CODIGOATENDIMENTO,\
        Mah.DATAHORAINICIO,\
        Mah.CODIGOPACIENTE,\
        Mah.NOMEPACIENTE,\
        Mah.DESCRICAOCONVENIO,\
        Mah.CODIGOITEM,\
        Mah.DESCRICAOITEM,\
        Mah.DESCRICAOESPECIALIDADE,\
        Mah.NOMESOLICITANTE,\
        Mah.VALOR\
 From Tbl_Mon_Alta_Hosp Mah        \
  where Mah.HR_ALTA_MEDICA>=(sysdate - interval '24' hour)\
  order by Mah.HR_ALTA_MEDICA;\
\
}