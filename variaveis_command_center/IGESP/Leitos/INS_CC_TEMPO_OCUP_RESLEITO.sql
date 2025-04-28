

BEGIN
-- Verifica e remove a view se já existir
   EXECUTE IMMEDIATE 'DROP VIEW  INVISUAL.INS_CC_TEMPO_OCUP_RESLEITO';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/


-- ======================================================================================
-- NOME DA DA VIEW: INS_CC_TEMPO_OCUP_RESLEITO
-- VARIÁVEL COMMAND CENTER: Leitos - Tempo de Leito Indisponível
-- PROPÓSITO:  Monitora leitos indisponivel por tipo de ocupacao - Reservado / Manutencao
-- CRIADO POR: Rodrigo
-- DATA DE CRIAÇÃO: **
-- ÚLTIMA ALTERAÇÃO: 28/04/2025 - Padronização de cabeçalho das views do IGESP
-- ======================================================================================



 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_TEMPO_OCUP_RESLEITO" as
 
 
 
 With MovLeito as (
select  codigoitem,
        CODIGOMULTIEMPRESA,
        TipoOcupacao,
        TIPOACOMODACAO,
        CodigoLeito ,
        DescricaoLeito,
        CodigoSetor,
        DescricaoSetor,
        CodigoUnidadeInternacao,
        DescricaoUnidadeInternacao,
        ( select   to_char(mInt.dt_mov_int, 'yyyy/mm/dd ') || to_char(mInt.hr_mov_int, 'hh24:Mi:ss') from DBAMV.MOV_INT mInt   where mInt.cd_mov_int =  MovLeito.codigoitem and mInt.cd_leito = MovLeito.CodigoLeito ) as DATAHORAINICIO ,
        (select  nm_usuario  from DBAMV.MOV_INT mInt   where mInt.cd_mov_int =  MovLeito.codigoitem and mInt.cd_leito = MovLeito.CodigoLeito  )   As NomeSolicitante ,
        (  select   round((Sysdate-mint.hr_mov_int)*1440) from DBAMV.MOV_INT mInt   where mInt.cd_mov_int =  MovLeito.codigoitem and mInt.cd_leito = MovLeito.CodigoLeito  ) as Valor

      From
(
select max(cd_mov_int)  as codigoitem,
         Setor.Cd_Multi_Empresa as CODIGOMULTIEMPRESA ,
         MovL.cd_leito  as CodigoLeito ,
         lto.ds_leito   as DescricaoLeito,
         UniInt.Cd_setor as CodigoSetor,
         Setor.Nm_Setor as DescricaoSetor,
         UniInt.cd_unid_int as CodigoUnidadeInternacao,
         UniInt.Ds_Unid_int as DescricaoUnidadeInternacao,
         Acomod.cd_tip_acom,
         Acomod.ds_tip_acom,
         CASE WHEN tp_ocupacao = 'R' THEN 'RESERVA'
              WHEN tp_ocupacao = 'M' THEN 'MANUTENCAO'
              END AS TipoOcupacao,
       case when ds_unid_int like 'PA%' OR ds_unid_int like '% PA' THEN 'PA'
       when lto.CD_TIP_ACOM IN (3,47) then  'UTI'   -- UTI
       WHEN lto.CD_TIP_ACOM in ( 1,2)  THEN 'UI  '  -- UI
       END TIPOACOMODACAO

         from dbamv.mov_int MovL
         join  dbamv.leito lto on MovL.cd_leito = lto.cd_leito
         join  dbamv.tip_acom Acomod on lto.cd_tip_acom = Acomod.cd_tip_acom
         join  dbamv.unid_int UniInt on lto.cd_unid_int = UniInt.cd_unid_int
         left join dbamv.Setor setor on  UniInt.Cd_Setor = Setor.Cd_setor

      where  MovL.tp_mov IN('R','M')
      and  lto.tp_ocupacao   IN ('R','M')
      and  UniInt.sn_ativo = 'S'
      and  lto.tp_situacao = 'A'
   --   and MovL.hr_mov_int >=(sysdate - interval '48' hour)
      group by MovL.cd_leito,
       Setor.Cd_Multi_Empresa,
        lto.tp_ocupacao,
               lto.ds_leito,
               UniInt.Cd_setor,
               Setor.Nm_Setor,
               UniInt.cd_unid_int,
               UniInt.Ds_Unid_int,
               Acomod.cd_tip_acom,
               Acomod.ds_tip_acom,
               lto.CD_TIP_ACOM
      order by  1 desc

)MovLeito


) ,


GiroLeito as (

select alta.CodigoLeito,
       alta.DescricaoLeito,
        CASE
        WHEN round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440) < 60 THEN
            round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440) || ' minutos'
        WHEN round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440) < 1440 THEN
            trunc(round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440) / 60) || ' horas ' ||
            mod(round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440), 60) || ' minutos'
        ELSE
            trunc(round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440) / 1440) || ' dias ' ||
            trunc(mod(round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440), 1440) / 60) || ' horas ' ||
            mod(round((limp.Hr_Fim_Limpeza - alta.HR_ALTA) * 1440), 60) || ' minutos'
    END AS UltimoGiroLeito

from
(SELECT
    MAX(atend.hr_alta) hr_alta,
    lim.cd_leito       AS codigoleito,
    lto.ds_leito       AS descricaoleito
FROM
         dbamv.atendime atend
    JOIN dbamv.solic_limpeza lim ON atend.cd_atendimento = lim.cd_atendimento
    JOIN dbamv.leito         lto ON lim.cd_leito = lto.cd_leito
WHERE
    atend.dt_alta IS NOT NULL
 -- AND lim.cd_leito = 1514
    AND lim.tp_solicitacao = 'A'
    AND hr_realizado IS NOT NULL
    AND dt_inicio_higieniza IS NOT NULL
GROUP BY
    lim.cd_leito,
    lto.ds_leito

)alta

Inner Join

(SELECT
    MAX(hr_realizado) hr_fim_limpeza,
    lim.cd_leito      AS codigoleito,
    lto.ds_leito      AS descricaoleito
FROM
         dbamv.atendime atend
    JOIN dbamv.solic_limpeza lim ON atend.cd_atendimento = lim.cd_atendimento
    JOIN dbamv.leito         lto ON lim.cd_leito = lto.cd_leito
WHERE
    atend.dt_alta IS NOT NULL
  --AND lim.cd_leito = 1514
    AND lim.tp_solicitacao = 'A'
    AND hr_realizado IS NOT NULL
    AND dt_inicio_higieniza IS NOT NULL
GROUP BY
    lim.cd_leito,
    lto.ds_leito
)limp On alta.CodigoLeito = Limp.CodigoLeito

Inner join MovLeito Ml On Ml.CodigoLeito = alta.CodigoLeito




)

SELECT
    ml.codigoitem,
    ml.codigomultiempresa,
    ml.tipoocupacao,
    ml.tipoacomodacao,
    ml.codigoleito,
    ml.descricaoleito,
    ml.codigosetor,
    ml.descricaosetor,
    ml.codigounidadeinternacao,
    ml.descricaounidadeinternacao,
    ml.datahorainicio,
    ml.nomesolicitante,
    ml.gl.ultimogiroleito,
    ml.valor
FROM
    movleito  ml
    LEFT JOIN giroleito gl ON ml.codigoleito = gl.codigoleito
WHERE   ml.codigoitem IN (
        SELECT
            cd_mov_int
        FROM
                 dbamv.mov_int movl
            JOIN dbamv.leito    lto ON movl.cd_leito = lto.cd_leito
            JOIN dbamv.tip_acom acomod ON lto.cd_tip_acom = acomod.cd_tip_acom
            JOIN dbamv.unid_int uniint ON lto.cd_unid_int = uniint.cd_unid_int
        WHERE
            movl.tp_mov IN('R','M')
            AND lto.tp_ocupacao IN('R','M')
            AND uniint.sn_ativo = 'S'
            AND lto.tp_situacao = 'A'
            AND movl.hr_lib_mov IS NULL
    );
