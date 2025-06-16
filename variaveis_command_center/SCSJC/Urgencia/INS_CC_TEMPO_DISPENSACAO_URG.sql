



BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_DISPENSACAO_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_DISPENSACAO_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Dispensação da Farmácia
-- PROPÓSITO: Monitora o tempo de dispensação de produtos pela farmacia na urgencia
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_DISPENSACAO_URG" as
  
  select distinct
  ATEND.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(ped.HR_SOLSAI_PRO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
ped.CD_SOLSAI_PRO as CODIGOPEDIDOFARMACIA,
item.CD_ITSOLSAI_PRO as CODIGOITEMPEDIDOFARMACIA,
item.CD_PRODUTO as CODIGOITEM,
prod.DS_PRODUTO as DESCRICAOITEM,
round((SYSDATE - ped.HR_SOLSAI_PRO) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
left join dbamv.solsai_pro ped on ped.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.prestador prest on prest.CD_PRESTADOR=ped.CD_PRESTADOR
left join dbamv.itsolsai_pro item on item.CD_SOLSAI_PRO=ped.CD_SOLSAI_PRO
left join dbamv.produto prod on prod.CD_PRODUTO=item.CD_PRODUTO
left join dbamv.especie esp on esp.CD_ESPECIE=prod.CD_ESPECIE
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and atend.cd_multi_empresa IN (1,7,9)
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO='U'
--and atend.CD_ORI_ATE not in (15)
and ped.TP_SITUACAO not in ('C','S')
and item.CD_ITSOLSAI_PRO is not null
--AND item.CD_SOLSAI_PRO = 11804085
and prod.CD_ESPECIE=1
--and prod.CD_PRODUTO not in (26152,4869,4878,4872,28168)
and (item.QT_ATENDIDA=0 or item.QT_ATENDIDA is null)
--and item.sn_conf_determ_usu='N'
order by DATAHORAINICIO;
