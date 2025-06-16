

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW INVISUAL.INS_CC_TEMPO_ATENDIMENTO_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_ATENDIMENTO_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Atendimento Médico Inicial
-- PROPÓSITO: Monitora pacientes aguardando atendimento médico na urgência
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================



-- Criação da view
CREATE OR REPLACE FORCE EDITIONABLE VIEW INVISUAL.INS_CC_TEMPO_ATENDIMENTO_URG AS
 select distinct
  ATEND.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(atend.HR_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as DESCRICAOITEM,
cor.NM_COR as NOMECOR,
round((SYSDATE - atend.HR_ATENDIMENTO) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.sacr_tempo_processo_historico hist on hist.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID

 -- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center
left join dbamv.triagem_atendimento triag on atend.cd_atendimento = triag.cd_atendimento
left join dbamv.SACR_CLASSIFICACAO_RISCO classif  on  classif.CD_TRIAGEM_ATENDIMENTO=triag.CD_TRIAGEM_ATENDIMENTO
left join dbamv.SACR_COR_REFERENCIA cor on cor.CD_COR_REFERENCIA=classif.CD_COR_REFERENCIA
-- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center

where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and atend.cd_multi_empresa IN (1,7,9)
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO='U'
--and atend.CD_ORI_ATE not in (15,96)
and hist.CD_TIPO_TEMPO_PROCESSO not in (30,31,32)
and (select count(*) from pre_med prem where prem.CD_ATENDIMENTO=atend.CD_ATENDIMENTO)=0
and (select count(*) from ped_lab lab where lab.CD_ATENDIMENTO=atend.CD_ATENDIMENTO)=0
and (select count(*) from ped_rx rx where rx.CD_ATENDIMENTO=atend.CD_ATENDIMENTO)=0
and (select count(*) from registro_documento doc where doc.CD_ATENDIMENTO=atend.CD_ATENDIMENTO)=0
and (select count(*) from PW_DOCUMENTO_CLINICO PWDOC where CD_ATENDIMENTO=atend.CD_ATENDIMENTO and   pwdoc.CD_TIPO_DOCUMENTO not in (2,20,27))=0
order by DATAHORAINICIO;
