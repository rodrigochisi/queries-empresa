{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_TEMPO_CHECAGEM_URG\
-- PROP\'d3SITO: Monitora o tempo de checagem dos medicamentos pela enfermagem\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_CHECAGEM_URG"  AS\
\
\
  select distinct \
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,\
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,\
TO_CHAR(ped.HR_PRE_MED, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,\
atend.CD_PACIENTE AS CODIGOPACIENTE,\
pac.NM_PACIENTE AS NOMEPACIENTE,\
conv.NM_CONVENIO as DESCRICAOCONVENIO,\
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
prest.NM_PRESTADOR as NOMESOLICITANTE,\
ped.CD_PRE_MED as CODIGOPRESCRICAO,\
item.CD_ITPRE_MED as CODIGOITEMPRESCRICAO,\
item.CD_TIP_PRESC as CODIGOITEM,\
presc.DS_TIP_PRESC as DESCRICAOITEM,\
round((SYSDATE - ped.HR_PRE_MED) * 1440) as VALOR\
from dbamv.atendime atend \
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE\
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO\
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA\
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID\
left join dbamv.pre_med ped on ped.CD_ATENDIMENTO=atend.CD_ATENDIMENTO\
left join dbamv.prestador prest on prest.CD_PRESTADOR=ped.CD_PRESTADOR\
left join dbamv.itpre_med item on item.CD_PRE_MED=ped.CD_PRE_MED\
left join dbamv.tip_presc presc on presc.CD_TIP_PRESC=item.CD_TIP_PRESC\
left join dbamv.hritpre_cons chec on chec.CD_ITPRE_MED=item.CD_ITPRE_MED\
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)\
and atend.DT_ALTA is null\
and atend.TP_ATENDIMENTO='U'\
and atend.CD_ORI_ATE not in (15)\
and item.CD_TIP_ESQ='MED'\
and item.SN_CANCELADO='N'\
and item.CD_ITPRE_MED is not null\
and chec.CD_ITPRE_MED is null\
and ped.FL_IMPRESSO='S'\
and item.SN_HORARIO_GERADO='S'\
order by DATAHORAINICIO;\
\
}