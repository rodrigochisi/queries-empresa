

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_MON_PAC_LEITO_EXTRA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_MON_PAC_LEITO_EXTRA
-- VARIÁVEL COMMAND CENTER: Leitos - Paciente em Leito Extra
-- PROPÓSITO: Monitora pacientes em leito extra - Pronto Atendimento / Internacao
-- CRIADO POR: Rodrigo
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================



 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_MON_PAC_LEITO_EXTRA"  AS SELECT
    CODIGOMULTIEMPRESA,
    CODIGOATENDIMENTO,
    TIPOLEITO,
    TIPOATENDIMENTO,
    DATAHORAINICIO,
    CODIGOPACIENTE,
    NOMEPACIENTE,
    DESCRICAOCONVENIO,
    NOMESOLICITANTE,
    DESCRICAOESPECIALIDADE,
    CODIGOLEITO,
    DESCRICAOLEITO,
    CODIGOSETOR,
    DESCRICAOSETOR,
    CODIGOUNIDADEINTERNACAO,
    DESCRICAOUNIDADEINTERNACAO,
    VALOR

from
(


  select
          atend.CD_ATENDIMENTO CodigoAtendimento,
          'LEITO CIRURGICO' TipoLeito,
          Case when atend.TP_ATENDIMENTO = 'I' THEN 'INTERNACAO'
           when atend.TP_ATENDIMENTO = 'U' THEN 'PRONTO ATENDIMENTO'
           end  TipoAtendimento ,
        atend.Cd_PAciente CodigoPaciente,
          unid.Cd_Setor CodigoSetor,
          Setor.Nm_Setor DescricaoSetor ,
          Dbamv.Obter_Iniciais_Com_Ponto(pac.NM_PACIENTE)  NomePaciente,
          Prest.Nm_Prestador NomeSolicitante ,
          atend.CD_MULTI_EMPRESA CodigoMultiEmpresa ,
          Esp.DS_Especialid DescricaoEspecialidade,
          unid.CD_UNID_INT CodigoUnidadeInternacao,
          unid.DS_UNID_INT DescricaoUnidadeInternacao,
          conv.NM_CONVENIO DescricaoConvenio,
          Atend.cd_leito CodigoLeito ,
          l.DS_LEITO  DescricaoLeito,
          TO_CHAR(atend.HR_ATENDIMENTO,'YYYY-MM-DD HH24:MI:ss') as DATAHORAINICIO ,
          round  ((sysdate - atend.HR_ATENDIMENTO )* 1440) as valor
from atendime atend
left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO
left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE
left join dbamv.leito l on l.CD_LEITO=atend.CD_LEITO
left join dbamv.unid_int unid on unid.CD_UNID_INT=l.CD_UNID_INT
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE
left join dbamv.Prestador Prest On atend.Cd_Prestador = Prest.Cd_Prestador
left join dbamv.Especialid Esp On Atend.cd_especialid=  Esp.cd_especialid
Left Join dbamv.Setor Setor On unid.Cd_Setor = Setor.Cd_Setor
    
where atend.TP_ATENDIMENTO IN ('I','U')
and atend.DT_ALTA is null
and l.SN_EXTRA='S'
AND  unid.DS_UNID_INT LIKE '%CIRURGICO%'

union all

  select
          atend.CD_ATENDIMENTO CodigoAtendimento,
           'LEITO NAO CIRURGICO' TipoLeito,
            Case when atend.TP_ATENDIMENTO = 'I' THEN 'INTERNACAO'
           when atend.TP_ATENDIMENTO = 'U' THEN 'PRONTO ATENDIMENTO'
           end  TipoAtendimento ,
          atend.Cd_PAciente CodigoPaciente,
          unid.Cd_Setor CodigoSetor,
          Setor.Nm_Setor DescricaoSetor ,
          Dbamv.Obter_Iniciais_Com_Ponto(pac.NM_PACIENTE)  NomePaciente,
          Prest.Nm_Prestador NomeSolicitante ,
          atend.CD_MULTI_EMPRESA CodigoMultiEmpresa ,
          Esp.DS_Especialid DescricaoEspecialidade ,
          unid.CD_UNID_INT CodigoUnidadeInternacao ,
          unid.DS_UNID_INT DescricaoUnidadeInternacao,
          conv.NM_CONVENIO DescricaoConvenio,
          Atend.cd_leito CodigoLeito ,
          l.DS_LEITO  DescricaoLeito,
          TO_CHAR(atend.HR_ATENDIMENTO,'YYYY-MM-DD HH24:MI:ss') as DATAHORAINICIO ,
          round  ((sysdate - atend.HR_ATENDIMENTO )* 1440) as valor
          
from atendime atend
left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO
left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE
left join dbamv.leito l on l.CD_LEITO=atend.CD_LEITO
left join dbamv.unid_int unid on unid.CD_UNID_INT=l.CD_UNID_INT
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE
left join dbamv.Prestador Prest On atend.Cd_Prestador = Prest.Cd_Prestador
left join dbamv.Especialid Esp On Atend.cd_especialid=  Esp.cd_especialid
Left Join dbamv.Setor Setor On unid.Cd_Setor = Setor.Cd_Setor
    
where atend.TP_ATENDIMENTO IN ('I','U')
and atend.DT_ALTA is null
and l.SN_EXTRA='S'
AND  unid.DS_UNID_INT NOT LIKE '%CIRURGICO%'

)where CODIGOMULTIEMPRESA IN (1,7,9);
