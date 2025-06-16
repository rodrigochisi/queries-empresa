
BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_COLETA_IMG_URG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_COLETA_IMG_URG
-- VARIÁVEL COMMAND CENTER: Urgência - Tempo de Realização de Exame de Imagem
-- PROPÓSITO: Monitora o tempo de realização de Exame de Imagem
-- CRIADO POR: Rubens
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_COLETA_IMG_URG"  AS
 
 SELECT DISTINCT
  atend.CD_MULTI_EMPRESA CODIGOMULTIEMPRESA,
ATEND.CD_ATENDIMENTO AS CODIGOATENDIMENTO,
TO_CHAR(PED.HR_PEDIDO, 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,
ATEND.CD_PACIENTE AS CODIGOPACIENTE,
dbamv.obter_iniciais_com_ponto(PAC.NM_PACIENTE) AS NOMEPACIENTE,
CONV.NM_CONVENIO AS DESCRICAOCONVENIO,
ESP.DS_ESPECIALID AS DESCRICAOESPECIALIDADE,
PREST.NM_PRESTADOR AS NOMESOLICITANTE,
PED.CD_PED_RX AS CodigoPedidoImg,
ITEM.CD_ITPED_RX AS CodigoItemPedidoImg,
ITEM.CD_EXA_RX AS CODIGOITEM,
DS_MODALIDADE_EXAME || '-' || EXA.DS_EXA_RX AS DESCRICAOITEM,
cor.NM_COR as NOMECOR,
ROUND((SYSDATE - PED.HR_PEDIDO) * 1440) AS VALOR
FROM dbamv.ATENDIME ATEND
LEFT JOIN dbamv.PACIENTE PAC ON ATEND.CD_PACIENTE=PAC.CD_PACIENTE
LEFT JOIN dbamv.CONVENIO CONV ON ATEND.CD_CONVENIO=CONV.CD_CONVENIO
LEFT JOIN dbamv.CON_PLA PLA ON ATEND.CD_CONVENIO=PLA.CD_CONVENIO AND ATEND.CD_CON_PLA=PLA.CD_CON_PLA
LEFT JOIN dbamv.ESPECIALID ESP ON ESP.CD_ESPECIALID=ATEND.CD_ESPECIALID
LEFT JOIN dbamv.PED_RX PED ON PED.CD_ATENDIMENTO=ATEND.CD_ATENDIMENTO
LEFT JOIN dbamv.PRESTADOR PREST ON PREST.CD_PRESTADOR=PED.CD_PRESTADOR
LEFT JOIN dbamv.ITPED_RX ITEM ON ITEM.CD_PED_RX=PED.CD_PED_RX
LEFT JOIN dbamv.EXA_RX EXA ON EXA.CD_EXA_RX=ITEM.CD_EXA_RX
LEFT JOIN dbamv.MODALIDADE_EXAME MODAL ON MODAL.CD_MODALIDADE_EXAME=EXA.CD_MODALIDADE_EXAME

 -- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center
LEFT JOIN dbamv.triagem_atendimento triag on atend.cd_atendimento = triag.cd_atendimento
LEFT JOIN dbamv.SACR_CLASSIFICACAO_RISCO classif  on  classif.CD_TRIAGEM_ATENDIMENTO=triag.CD_TRIAGEM_ATENDIMENTO
LEFT JOIN dbamv.SACR_COR_REFERENCIA cor on cor.CD_COR_REFERENCIA=classif.CD_COR_REFERENCIA
-- Adiconado dia 24/09/2024  , para adiconar o tipo de cor e separar na nova regra no Command Center
WHERE ATEND.HR_ATENDIMENTO>=(sysdate - interval '10' hour)
and atend.cd_multi_empresa  IN (1,7,9)
AND ATEND.DT_ALTA IS NULL
AND ATEND.TP_ATENDIMENTO='U'
AND ITEM.CD_ITPED_RX IS NOT NULL
AND ITEM.CD_LAUDO IS NULL
And ITEM.CD_ITPED_RX in  (select lep.cd_item_pedido_his
                          from   idce.rs_lau_pedido_exame lpe
                            join idce.rs_lau_exame_pedido lep
                          on lpe.id_pedido_exame = lep.id_pedido_exame
                          where dt_study is null
                          ) --- Condicao necessaria , pois , existe a integracao com o VIVACE, entao a data do mesmo vem dessas tabelas
And ITEM.DT_REALIZADO IS NULL
-- AND MODAL.DS_SIGLA_MODALIDADE<>'RX'
AND ITEM.DT_SOLICITACAO_GUIA IS NULL
and    lower(ds_exa_rx)  not  like '%eletro%'
and     lower(ds_exa_rx) not like  '%holter%'
order by DATAHORAINICIO;
