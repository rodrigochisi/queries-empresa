{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ======================================================================================\
-- VIEW: INS_CC_CONV_VALOR_FORA_PACOTE\
-- PROP\'d3SITO: Monitora pacientes convenio com item fora do pacote\
-- CRIADO POR:  Rodrigo  / Gustavo\
-- DATA DE CRIA\'c7\'c3O: 2024-04-15\
-- \'daLTIMA ALTERA\'c7\'c3O: 2024-04-15 por Fulano - [JIRA-123] Ajuste em filtros de data\
-- ======================================================================================\
\
\
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "INVISUAL"."INS_CC_CONV_VALOR_FORA_PACOTE"  AS\
 \
 \
  SELECT  \
    A.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,  \
    C2.NM_CONVENIO AS DESCRICAOCONVENIO,  \
    A.CD_ATENDIMENTO AS CODIGOATENDIMENTO,  \
    'PS'AS TIPOATENDIMENTO, \
    RA.CD_REG_AMB AS CODIGOCONTA,  \
    A.CD_PACIENTE AS CODIGOPACIENTE,  \
    P.NM_PACIENTE AS NOMEPACIENTE,  \
    TO_CHAR(IRA.HR_LANCAMENTO, 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,  \
    IRA.CD_PRO_FAT AS CODIGOITEM,  \
    PF.DS_PRO_FAT AS DESCRICAOITEM,  \
    round(IRA.VL_TOTAL_CONTA) AS VALOR\
        \
\
FROM DBAMV.REG_AMB RA  \
LEFT JOIN DBAMV.ITREG_AMB IRA ON RA.CD_REG_AMB = IRA.CD_REG_AMB  \
LEFT JOIN DBAMV.CONVENIO C1 ON RA.CD_CONVENIO = C1.CD_CONVENIO  \
LEFT JOIN DBAMV.ATENDIME A ON IRA.CD_ATENDIMENTO = A.CD_ATENDIMENTO  \
LEFT JOIN DBAMV.CONVENIO C2 ON A.CD_CONVENIO = C2.CD_CONVENIO  \
LEFT JOIN DBAMV.PACIENTE P ON A.CD_PACIENTE = P.CD_PACIENTE  \
LEFT JOIN DBAMV.PRO_FAT PF ON IRA.CD_PRO_FAT = PF.CD_PRO_FAT  \
 WHERE     1=1\
       and ira.hr_lancamento >= sysdate - interval '24' hour\
       --AND A.DT_ATENDIMENTO >= TO_DATE ('01/01/2025', 'DD/MM/YYYY')\
       AND A.TP_ATENDIMENTO = 'U'\
       AND C1.TP_CONVENIO = 'P'\
       AND C2.TP_CONVENIO = 'C'\
       AND IRA.SN_PERTENCE_PACOTE = 'N'\
       AND NVL (IRA.TP_PAGAMENTO, 'P') <> 'C'\
       AND NVL (RA.SN_DIAGNO, 'N') = 'N'\
       AND IRA.VL_TOTAL_CONTA > 0\
       AND ROUND (\
                 (  IRA.VL_TOTAL_CONTA\
                  / (SELECT SUM (IRA2.VL_TOTAL_CONTA)\
                       FROM DBAMV.ITREG_AMB IRA2\
                      WHERE     IRA2.CD_REG_AMB = RA.CD_REG_AMB\
                            AND IRA2.SN_PERTENCE_PACOTE = 'N'))\
               * (SELECT   SUM (NVL (RCR.VL_RECEBIDO, 0))\
                         - SUM (NVL (RCR.VL_ACRESCIMO, 0))\
                         + SUM (NVL (RCR.VL_DESCONTO, 0))\
                    FROM DBAMV.RECCON_REC  RCR\
                         JOIN DBAMV.ITCON_REC ICR\
                             ON RCR.CD_ITCON_REC = ICR.CD_ITCON_REC\
                         JOIN DBAMV.CON_REC CR\
                             ON ICR.CD_CON_REC = CR.CD_CON_REC\
                   WHERE     CR.CD_ATENDIMENTO = A.CD_ATENDIMENTO\
                         AND CR.CD_REG_AMB = RA.CD_REG_AMB),\
               2)\
               IS NULL\
\
\
\
\
\
\
 UNION ALL \
\
 SELECT  \
    A.CD_MULTI_EMPRESA AS CODIGOMULTIEMPRESA,  \
    C2.NM_CONVENIO AS DESCRICAOCONVENIO,  \
    A.CD_ATENDIMENTO AS CODIGOATENDIMENTO,  \
    'INTERNACAO' AS TIPOATENDIMENTO,\
    RF.CD_REG_FAT AS CODIGOCONTA,  \
    A.CD_PACIENTE AS CODIGOPACIENTE,  \
    P.NM_PACIENTE AS NOMEPACIENTE,  \
    TO_CHAR(IFA.HR_LANCAMENTO, 'YYYY-MM-DD HH24:MI:SS') AS DATAHORAINICIO,  \
    IFA.CD_PRO_FAT AS CODIGOITEM,  \
    PF.DS_PRO_FAT AS DESCRICAOITEM,  \
    round(IFA.VL_TOTAL_CONTA) AS VALOR\
\
\
\
\
FROM DBAMV.REG_FAT RF  \
LEFT JOIN DBAMV.ITREG_FAT IFA ON RF.CD_REG_FAT = IFA.CD_REG_FAT  \
LEFT JOIN DBAMV.CONVENIO C1 ON RF.CD_CONVENIO = C1.CD_CONVENIO  \
LEFT JOIN DBAMV.ATENDIME A ON RF.CD_ATENDIMENTO = A.CD_ATENDIMENTO  \
LEFT JOIN DBAMV.CONVENIO C2 ON A.CD_CONVENIO = C2.CD_CONVENIO  \
LEFT JOIN DBAMV.PACIENTE P ON A.CD_PACIENTE = P.CD_PACIENTE  \
LEFT JOIN DBAMV.PRO_FAT PF ON IFA.CD_PRO_FAT = PF.CD_PRO_FAT  \
 WHERE 1=1\
       and ifa.hr_lancamento >= sysdate - interval '24' hour\
       --and A.DT_ATENDIMENTO >= TO_DATE ('01/01/2025', 'DD/MM/YYYY')\
       AND A.TP_ATENDIMENTO = 'I'\
       AND A.DT_ALTA IS NULL\
       AND C1.TP_CONVENIO = 'P'\
       AND C2.TP_CONVENIO = 'C'\
       AND IFA.SN_PERTENCE_PACOTE = 'N'\
       AND NVL (IFA.TP_PAGAMENTO, 'P') <> 'C'\
       AND NVL (RF.SN_DIAGNO, 'N') = 'N'\
       AND IFA.VL_TOTAL_CONTA > 0\
       AND   (  IFA.VL_TOTAL_CONTA\
              / (SELECT SUM (IFA2.VL_TOTAL_CONTA)\
                   FROM DBAMV.ITREG_FAT IFA2\
                  WHERE     IFA2.CD_REG_FAT = RF.CD_REG_FAT\
                        AND IFA2.SN_PERTENCE_PACOTE = 'N'))\
           * (SELECT   SUM (NVL (RCR.VL_RECEBIDO, 0))\
                     - SUM (NVL (RCR.VL_ACRESCIMO, 0))\
                     + SUM (NVL (RCR.VL_DESCONTO, 0))\
                FROM DBAMV.RECCON_REC  RCR\
                     JOIN DBAMV.ITCON_REC ICR\
                         ON RCR.CD_ITCON_REC = ICR.CD_ITCON_REC\
                     JOIN DBAMV.CON_REC CR ON ICR.CD_CON_REC = CR.CD_CON_REC\
               WHERE     CR.CD_ATENDIMENTO = A.CD_ATENDIMENTO\
                     AND CR.CD_REG_FAT = RF.CD_REG_FAT)\
               IS NULL;\
\
}