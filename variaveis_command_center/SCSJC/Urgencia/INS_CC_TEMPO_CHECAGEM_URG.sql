
BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_CHECAGEM_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_CHECAGEM_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Checagem da Enfermagem
-- PROPÓSITO: Monitora o tempo de checagem dos medicamentos pela enfermagem
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_CHECAGEM_URG"  AS
 select distinct
--item.ds_itpre_med,
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(ped.HR_PRE_MED, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
ped.CD_PRE_MED as CODIGOPRESCRICAO,
item.CD_ITPRE_MED as CODIGOITEMPRESCRICAO,
item.CD_TIP_PRESC as CODIGOITEM,
presc.DS_TIP_PRESC as DESCRICAOITEM,
round((SYSDATE - ped.HR_PRE_MED) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
left join dbamv.pre_med ped on ped.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.prestador prest on prest.CD_PRESTADOR=ped.CD_PRESTADOR
left join dbamv.itpre_med item on item.CD_PRE_MED=ped.CD_PRE_MED
left join dbamv.tip_presc presc on presc.CD_TIP_PRESC=item.CD_TIP_PRESC
left join dbamv.hritpre_cons chec on chec.CD_ITPRE_MED=item.CD_ITPRE_MED
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and atend.cd_multi_empresa IN (1,7,9)
and atend.DT_ALTA is   null

and atend.TP_ATENDIMENTO='U'
--and atend.CD_ORI_ATE not in (15)
and item.CD_TIP_ESQ='MDN'
and item.tp_situacao = 'S'
 and ( upper(item.ds_itpre_med) not like 'SE%' and  upper(item.ds_itpre_med) not like '%EM CASO%' ) --- tirar medicacao Se Necessario
and item.SN_CANCELADO='N'
and item.CD_ITPRE_MED is not null
and chec.CD_ITPRE_MED is null
and ped.FL_IMPRESSO='S'
and item.SN_HORARIO_GERADO='S'
order by DATAHORAINICIO;
