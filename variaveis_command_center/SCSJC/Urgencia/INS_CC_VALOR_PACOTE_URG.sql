

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_VALOR_PACOTE_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_VALOR_PACOTE_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Valor Gasto no PS
-- PROPÓSITO: Monitora o valor do pacote de pacientes na urgencia
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_VALOR_PACOTE_URG"  AS
 
 SELECT
         atend.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,
         conv.NM_CONVENIO as DESCRICAOCONVENIO,
         atend.CD_ATENDIMENTO as CODIGOATENDIMENTO,
         pac.CD_PACIENTE as CODIGOPACIENTE,
         dbamv.obter_iniciais_com_ponto(pac.NM_PACIENTE) as NOMEPACIENTE,
         esp.DS_ESPECIALID as DESCRICAOESPECIALIDADE,
         prest.NM_PRESTADOR as NOMESOLICITANTE,
         atend.CD_ATENDIMENTO as CODIGOITEM,
         ori.DS_ORI_ATE as DESCRICAOITEM,
         TO_CHAR(atend.HR_ATENDIMENTO,  'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,
         ROUND(COALESCE((select SUM(itreg.VL_TOTAL_CONTA) from itreg_amb itreg where itreg.cd_atendimento=atend.CD_ATENDIMENTO),0)) as VALOR
         from dbamv.atendime atend
         left join dbamv.convenio conv on conv.CD_CONVENIO=atend.CD_CONVENIO
         left join dbamv.paciente pac on pac.CD_PACIENTE=atend.CD_PACIENTE
         left join dbamv.especialid esp on esp.CD_ESPECIALID=atend.CD_ESPECIALID
         left join dbamv.prestador prest on prest.CD_PRESTADOR=atend.CD_PRESTADOR
         left join dbamv.ori_ate ori on ori.CD_ORI_ATE=atend.CD_ORI_ATE
         where atend.DT_ALTA IS NULL
         and  atend.CD_MULTI_EMPRESA IN (1,7,9)
         AND atend.TP_ATENDIMENTO = 'U'
         AND atend.HR_ATENDIMENTO>=(sysdate - interval '10' hour);
