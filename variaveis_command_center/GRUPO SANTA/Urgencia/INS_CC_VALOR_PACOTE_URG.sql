{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_VALOR_PACOTE_URG\
-- PROP\'d3SITO: Monitora o valor do pacote de pacientes na urg\'eancia\
-- CRIADO POR:  Rubens\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_VALOR_PACOTE_URG"  AS\
\
\
  SELECT   \
         atend.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,\
         conv.NM_CONVENIO as DESCRICAOCONVENIO,\
         atend.CD_ATENDIMENTO as CODIGOATENDIMENTO,\
         pac.CD_PACIENTE as CODIGOPACIENTE, \
         pac.NM_PACIENTE as NOMEPACIENTE,\
         esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,\
         prest.NM_PRESTADOR as NOMESOLICITANTE,\
         atend.CD_ATENDIMENTO as CODIGOITEM,\
         ori.DS_ORI_ATE as DESCRICAOITEM,\
         TO_CHAR(atend.HR_ATENDIMENTO,  'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,\
         ROUND(COALESCE((select SUM(itreg.VL_TOTAL_CONTA) from itreg_amb itreg where itreg.cd_atendimento=atend.CD_ATENDIMENTO),0)) as VALOR\
         from dbamv.atendime atend\
         left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO\
         left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE\
         left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID\
         left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR\
         left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE\
         where atend.DT_ALTA IS NULL\
         AND atend.TP_ATENDIMENTO = 'U'\
         AND atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour);\
\
\
}