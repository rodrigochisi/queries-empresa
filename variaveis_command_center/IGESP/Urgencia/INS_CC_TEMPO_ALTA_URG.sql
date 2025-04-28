

-- Verifica e remove a view se já existir
 BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW INVISUAL.INS_CC_TEMPO_ALTA_URG';
 EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
 END;
 /


-- ======================================================================================
-- VIEW: INS_CC_TEMPO_ALTA_URG
-- VARIÁVEL COMMAND CENTER : IGESP - Paulista - PS - Pacientes Aguardando Alta
-- PROPÓSITO: Monitora pacientes na urgencia aguardando alta
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO:  **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_ALTA_URG"  AS
 select distinct
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(atend.HR_ATENDIMENTO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
atend.CD_ORI_ATE as CODIGOITEM,
ori.DS_ORI_ATE as DESCRICAOITEM,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
round((SYSDATE - atend.HR_ATENDIMENTO) * 1440) as VALOR

from dbamv.atendime atend
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE
left join dbamv.setor setor on setor.CD_SETOR=ori.CD_SETOR
left join dbamv.sacr_tempo_processo_historico hist on hist.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
where atend.HR_ATENDIMENTO>=(sysdate - interval '24' hour)
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO='U'
--and atend.CD_ORI_ATE not in (15,96)
order by DATAHORAINICIO;
