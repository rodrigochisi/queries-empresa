
BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW INVISUAL.INS_CC_TEMPO_AUTORIZACAO_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_AUTORIZACAO_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Autorização de Procedimentos
-- PROPÓSITO: Monitora o tempo de autorizacao da guia na urgencia
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================



-- Criação da view

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_AUTORIZACAO_URG"  AS
 select
 CODIGOMULTIEMPRESA,
 CODIGOATENDIMENTO,
 DATAHORAINICIO,
 CODIGOPACIENTE,
 NOMEPACIENTE,
 DESCRICAOCONVENIO,
 DESCRICAOESPECIALIDADE,
 NOMESOLICITANTE,
 CODIGOGUIA,
 CODIGOITEMGUIA,
 CODIGOITEM,
 DESCRICAOITEM,
 VALOR
from
(
 

  select distinct
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(guia.DT_GERACAO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
guia.CD_GUIA as CODIGOGUIA,
item.CD_IT_GUIA as CODIGOITEMGUIA,
item.CD_PRO_FAT as CODIGOITEM,
pro.DS_PRO_FAT as DESCRICAOITEM,
round((SYSDATE - guia.DT_GERACAO) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
left join dbamv.guia guia on guia.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.it_GUIA item on item.CD_GUIA=guia.CD_GUIA
left join dbamv.pro_fat pro on pro.CD_PRO_FAT=item.CD_PRO_FAT
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and  atend.cd_multi_empresa = 1
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO='U'
and guia.CD_GUIA is not null
and guia.TP_SITUACAO='P'


union all


 select distinct
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(guia.DT_GERACAO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
atend.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
conv.NM_CONVENIO as DESCRICAOCONVENIO,
esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
prest.NM_PRESTADOR as NOMESOLICITANTE,
guia.CD_GUIA as CODIGOGUIA,
item.CD_IT_GUIA as CODIGOITEMGUIA,
item.CD_PRO_FAT as CODIGOITEM,
pro.DS_PRO_FAT as DESCRICAOITEM,
round((SYSDATE - guia.DT_GERACAO) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
left join dbamv.guia guia on guia.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.it_GUIA item on item.CD_GUIA=guia.CD_GUIA
left join dbamv.pro_fat pro on pro.CD_PRO_FAT=item.CD_PRO_FAT
where atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and  atend.cd_multi_empresa= 7
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO='U'
and guia.CD_GUIA is not null
and guia.TP_SITUACAO='P'
 
union all

select distinct
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
  atend.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
  TO_CHAR(guia.DT_GERACAO, 'YYYY-MM-DD HH24:MI:SS') as DATAHORAINICIO,
  atend.CD_PACIENTE AS CODIGOPACIENTE,
  dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) AS NOMEPACIENTE,
  conv.NM_CONVENIO as DESCRICAOCONVENIO,
  esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
  prest.NM_PRESTADOR as NOMESOLICITANTE,
  guia.CD_GUIA as CODIGOGUIA,
  item.CD_IT_GUIA as CODIGOITEMGUIA,
  item.CD_PRO_FAT as CODIGOITEM,
  pro.DS_PRO_FAT as DESCRICAOITEM,
  round((SYSDATE - guia.DT_GERACAO) * 1440) as VALOR
from dbamv.atendime atend
left join dbamv.paciente pac on atend.CD_PACIENTE=pac.CD_PACIENTE
left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
left join dbamv.convenio conv on atend.CD_CONVENIO=conv.CD_CONVENIO
left join dbamv.con_pla pla on atend.CD_CONVENIO=pla.CD_CONVENIO and atend.CD_CON_PLA=pla.CD_CON_PLA
left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
left join dbamv.guia guia on guia.CD_ATENDIMENTO=atend.CD_ATENDIMENTO
left join dbamv.it_GUIA item on item.CD_GUIA=guia.CD_GUIA
left join dbamv.pro_fat pro on pro.CD_PRO_FAT=item.CD_PRO_FAT
where atend.HR_ATENDIMENTO >= (sysdate - interval '10' hour)
and atend.cd_multi_empresa = 9
and atend.DT_ALTA is null
and atend.TP_ATENDIMENTO = 'U'
and guia.CD_GUIA is not null
and guia.TP_SITUACAO = 'P'

AND NOT EXISTS ( -- Condicao para eliminar Atendimentos de Retorno E Procedimento  for Consulta .
    SELECT 1
    FROM dbamv.atendime atend_ret
    JOIN dbamv.it_GUIA item_ret ON item_ret.CD_GUIA = guia.CD_GUIA
    JOIN dbamv.pro_fat pro_ret ON pro_ret.CD_PRO_FAT = item_ret.CD_PRO_FAT
    WHERE atend_ret.CD_PACIENTE = atend.CD_PACIENTE
    AND atend_ret.CD_ATENDIMENTO <> atend.CD_ATENDIMENTO
    AND atend_ret.TP_ATENDIMENTO = 'U'
    AND atend_ret.CD_MULTI_EMPRESA = 9
    AND atend_ret.HR_ATENDIMENTO BETWEEN atend.HR_ATENDIMENTO - INTERVAL '24' HOUR AND atend.HR_ATENDIMENTO
    AND pro_ret.DS_PRO_FAT LIKE '%CONSULTA%'
)
-- and nvl(atend.sn_retorno,'N') = 'N'
and (
    -- Para FUNDACAO SAO FRANCISCO XAVIER, eliminar grupos 28 e 35 (PATOLOGIA CLINICA e RADIOTERAPIA)
    (atend.CD_CONVENIO = 202 and pro.CD_GRU_PRO not in (28,32,35 ))

    -- Para NOTRE DAME e NOTRE DAME INTERMEDICA, eliminar procedimentos com 'COVID' no nome
    or (atend.CD_CONVENIO in (14, 39) and pro.DS_PRO_FAT not like '%COVID%')

    -- Para todos os outros convênios, traz tudo
    or (atend.CD_CONVENIO not in (202, 14, 39))
  )
  );
