{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_MON_PAC_LEITO_EXTRA\
-- PROP\'d3SITO: Monitora pacientes em leito extra - cir\'fargico / n\'e3o cir\'fargico	\
-- CRIADO POR:  Rodrigo \
-- DATA DE CRIA\'c7\'c3O: 15/04/2025\
-- \'daLTIMA ALTERA\'c7\'c3O: 15/04/2025  por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_MON_PAC_LEITO_EXTRA"  AS\
  select CodigoMultiEmpresa,\
       CodigoAtendimento, \
       TipoRegra,\
       DataHoraInicio,\
       CodigoPaciente,\
       NomePaciente,\
       DescricaoConvenio,\
       NomeSolicitante,\
       DescricaoEspecialidade,\
       CodigoLeito,\
       DescricaoLeito,\
       CodigoSetor,\
       DescricaoSetor,\
       CodigoUnidadeInternacao,\
       DescricaoUnidadeInternacao,\
       Valor\
from \
( \
\
\
  select  \
          atend.CD_ATENDIMENTO CodigoAtendimento, \
          'LEITO  CIRURGICO' TipoRegra, \
          atend.Cd_PAciente CodigoPaciente, \
          unid.Cd_Setor CodigoSetor, \
          Setor.Nm_Setor DescricaoSetor , \
          pac.NM_PACIENTE  NomePaciente,  \
          Prest.Nm_Prestador NomeSolicitante , \
          atend.CD_MULTI_EMPRESA CodigoMultiEmpresa , \
          Esp.DS_Especialid DescricaoEspecialidade,\
          unid.CD_UNID_INT CodigoUnidadeInternacao,\
          unid.DS_UNID_INT DescricaoUnidadeInternacao,\
          conv.NM_CONVENIO DescricaoConvenio, \
          Atend.cd_leito CodigoLeito , \
          l.DS_LEITO  DescricaoLeito,\
          TO_CHAR(atend.HR_ATENDIMENTO,'YYYY-MM-DD HH24:MI:ss') as DATAHORAINICIO ,\
          round  ((sysdate - atend.HR_ATENDIMENTO )* 1440) as VALOR \
from atendime atend \
left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO\
left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE\
left join dbamv.leito l on l.CD_LEITO=atend.CD_LEITO\
left join dbamv.unid_int unid on unid.CD_UNID_INT=l.CD_UNID_INT\
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE\
left join dbamv.Prestador Prest On atend.Cd_Prestador = Prest.Cd_Prestador \
left join dbamv.Especialid Esp On Atend.cd_especialid=  Esp.cd_especialid    \
Left Join dbamv.Setor Setor On unid.Cd_Setor = Setor.Cd_Setor \
    \
where atend.TP_ATENDIMENTO='I'\
and atend.DT_ALTA is null\
--and atend.CD_MULTI_EMPRESA=1\
and l.CD_UNID_INT=19\
and l.SN_EXTRA='S'\
\
\
union all \
\
\
\
  select \
          atend.CD_ATENDIMENTO CodigoAtendimento, \
          'LEITO NAO CIRURGICO' TipoRegra, \
          atend.Cd_PAciente CodigoPaciente, \
          unid.Cd_Setor CodigoSetor, \
          Setor.Nm_Setor DescricaoSetor , \
          pac.NM_PACIENTE  NomePaciente,   \
          Prest.Nm_Prestador NomeSolicitante , \
          atend.CD_MULTI_EMPRESA CodigoMultiEmpresa , \
          Esp.DS_Especialid DescricaoEspecialidade ,\
          unid.CD_UNID_INT CodigoUnidadeInternacao ,\
          unid.DS_UNID_INT DescricaoUnidadeInternacao,\
          conv.NM_CONVENIO DescricaoConvenio,\
          Atend.cd_leito CodigoLeito , \
          l.DS_LEITO  DescricaoLeito,\
          TO_CHAR(atend.HR_ATENDIMENTO,'YYYY-MM-DD HH24:MI:ss') as DATAHORAINICIO , \
          round  ((sysdate - atend.HR_ATENDIMENTO )* 1440) as valor \
          \
from atendime atend \
left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO\
left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE\
left join dbamv.leito l on l.CD_LEITO=atend.CD_LEITO\
left join dbamv.unid_int unid on unid.CD_UNID_INT=l.CD_UNID_INT\
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE\
left join dbamv.Prestador Prest On atend.Cd_Prestador = Prest.Cd_Prestador \
left join dbamv.Especialid Esp On Atend.cd_especialid=  Esp.cd_especialid    \
Left Join dbamv.Setor Setor On unid.Cd_Setor = Setor.Cd_Setor \
    \
where atend.TP_ATENDIMENTO='I'\
and atend.DT_ALTA is null\
--and atend.CD_MULTI_EMPRESA=1\
and l.CD_UNID_INT <>19\
and l.SN_EXTRA='S'\
and  l.DS_LEITO not like '%BERCARIO%'\
);\
\
}