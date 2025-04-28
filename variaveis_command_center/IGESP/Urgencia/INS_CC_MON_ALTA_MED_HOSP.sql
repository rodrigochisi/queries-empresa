-- Verifica e remove a view se já existir
BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW INVISUAL.INS_CC_MON_ALTA_MED_HOSP';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- ======================================================================================
-- VIEW: INS_CC_MON_ALTA_MED_HOSP
-- VARIÁVEL COMMAND CENTER : Leitos - Tempo de Alta Hospitalar 
-- PROPÓSITO: Monitora alta hospitalar de pacientes com alta médica
-- CRIADO POR: Rodrigo
-- DATA DE CRIAÇÃO:  ** 2024
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP 
-- ======================================================================================

CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_MON_ALTA_MED_HOSP" AS

with Tbl_Mon_Alta_Hosp As (
  select distinct
  atend.HR_ALTA_MEDICA,
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(atend.HR_ALTA_MEDICA, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') DATAATUAL,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
atend.CD_ORI_ATE as CODIGOITEM,
ori.DS_ORI_ATE as DESCRICAOITEM,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
round((SYSDATE - atend.HR_ALTA_MEDICA) * 1440) as VALOR

from dbamv.atendime atend
left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE
left join dbamv.setor setor on setor.CD_SETOR=ori.CD_SETOR
left join dbamv.sacr_tempo_processo_historico hist on hist.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID

Where ( (atend.HR_ALTA_MEDICA BETWEEN SYSDATE - INTERVAL '24' HOUR AND SYSDATE + INTERVAL '24' HOUR)
        OR (atend.DT_ALTA_MEDICA BETWEEN SYSDATE - INTERVAL '24' HOUR AND SYSDATE + INTERVAL '24' HOUR)
       )
and atend.HR_ALTA_MEDICA is not null
and atend.DT_ALTA is null
and atend.tp_atendimento = 'I'


)

select  Mah.CODIGOMULTIEMPRESA,
        Mah.CODIGOATENDIMENTO,
        Mah.DATAHORAINICIO,
        Mah.CODIGOPACIENTE,
        Mah.NOMEPACIENTE,
        Mah.DESCRICAOCONVENIO,
        Mah.CODIGOITEM,
        Mah.DESCRICAOITEM,
        Mah.DESCRICAOESPECIALIDADE,
        Mah.NOMESOLICITANTE,
        Mah.VALOR
 From Tbl_Mon_Alta_Hosp Mah
 -- where Mah.HR_ALTA_MEDICA>=(sysdate - interval '24' hour)
  where case when Mah.DATAHORAINICIO >= MAH.DATAATUAL then 0
  else 1 end = 1 -- Condicao necessaria , pois existe casos que o medico coloca a data no futuro ( vai considerar a alta medica quando a data e a hora da alta for maior ou igual a data e hora atual)
  and   Mah.CODIGOMULTIEMPRESA IN (1,7,9)

  order by Mah.HR_ALTA_MEDICA;
