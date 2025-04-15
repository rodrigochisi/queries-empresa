{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_PERC_ADIANT_CONTA\
-- PROP\'d3SITO: Monitora o valor da conta e compara com o adiantamento. Dispara alerta quando o valor da conta tinge 90% do adiantamento\
-- CRIADO POR:  Rodrigo / Gustavo\
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_PERC_ADIANT_CONTA"  AS\
\
select\
  atend.cd_multi_empresa as CODIGOMULTIEMPRESA\
  ,atend.cd_atendimento as CODIGOATENDIMENTO\
  ,to_char(atend.dt_atendimento,  'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO\
  ,atend.cd_paciente as CODIGOPACIENTE\
  ,pac.nm_paciente as NOMEPACIENTE\
  ,listagg(rf.cd_reg_fat, ', ') within group(order by rf.cd_reg_fat) as CODIGOCONTA\
  ,round(nvl(sum(rf.vl_total_conta), 0) / nullif((nvl(caucao.vl_caucao, 0) + nvl(cont.vl_contrato_adiant, 0)), 0), 2)*100 as VALOR\
from dbamv.atendime atend\
left join dbamv.convenio conv on atend.cd_convenio = conv.cd_convenio\
left join dbamv.paciente pac on atend.cd_paciente = pac.cd_paciente\
left join dbamv.reg_fat rf on atend.cd_atendimento = rf.cd_atendimento\
left join (\
  select cd_atendimento, sum(vl_caucao) as vl_caucao\
  from dbamv.caucao\
  group by cd_atendimento\
) caucao on atend.cd_atendimento = caucao.cd_atendimento\
left join (\
  select cd_atendimento, sum(vl_contrato_adiant) as vl_contrato_adiant\
  from dbamv.contrato_adiantamento\
  where sn_recebido = 'S'\
  group by cd_atendimento\
) cont on atend.cd_atendimento = cont.cd_atendimento\
where 1=1\
and atend.tp_atendimento = 'I'\
and conv.tp_convenio = 'P'\
and atend.dt_atendimento >= to_date('01/01/' || to_char(sysdate, 'yyyy'), 'dd/mm/yyyy')\
and atend.dt_alta is null\
group by\
  atend.cd_multi_empresa\
  ,atend.cd_atendimento\
  ,to_char(atend.dt_atendimento,  'YYYY-MM-DD HH24:MI:SS')\
  ,atend.cd_paciente\
  ,pac.nm_paciente\
  ,caucao.vl_caucao\
  ,cont.vl_contrato_adiant\
having\
  nvl(caucao.vl_caucao, 0) + nvl(cont.vl_contrato_adiant, 0) > 0\
  and nvl(sum(rf.vl_total_conta), 0) >= (nvl(caucao.vl_caucao, 0) + nvl(cont.vl_contrato_adiant, 0)) * 0.9 --conta atingiu 90%+ do valor adiantado\
order by\
  atend.cd_atendimento}