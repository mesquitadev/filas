SELECT 'EQTL PI'                                                      AS Empresa,
       'A'                                                               atros_status,
       TO_CHAR(oc.oco_data_nr, 'DD/MM/YYYY')                             data_abertura,
       SYSDATE                                                           data_carga,
       'ATENDIMENTO_EMEGENCIAL'                                          processo,
       TO_CHAR(oc.oco_data_nr, 'HH24:MI:SS')                          AS hora_entrada,
       oc.oco_data_acionamento,
       TO_CHAR(oc.oco_data_acionamento, 'HH24:MI:SS')                 AS hora_acionamento,
       oc.oco_data_aceite,
       TO_CHAR(oc.oco_data_aceite, 'HH24:MI:SS')                      AS hora_aceite,
       oc.oco_data_chegada,
       TO_CHAR(oc.oco_data_chegada, 'HH24:MI:SS')                     AS hora_chegada,
       oc.oco_data_conclusao,
       TO_CHAR(oc.oco_data_conclusao, 'HH24:MI:SS')                   AS hora_conclusao,
       '="'
           || io.iop_num
           || '"'                                                        equipamento,
       round((oc.oco_data_aceite - oc.oco_data_nr) * 24, 3)              tmp,
       round((oc.oco_data_chegada - oc.oco_data_aceite) * 24, 3)         tmd,
       round((oc.oco_data_conclusao - oc.oco_data_chegada) * 24, 3)      tma,
       round((oc.oco_data_aceite - oc.oco_data_nr) * 24 + (oc.oco_data_chegada - oc.oco_data_aceite) * 24 +
             (oc.oco_data_conclusao
                 - oc.oco_data_chegada) * 24, 3)                         tmat,
       (SELECT MAX(mr.latitude)
        FROM operacao.atribui_oc_emergencial ae1
                 LEFT JOIN operacao.atribui_oc_mensagem_retorno mr ON mr.atribuicao_oc_id = ae1.atribuicao_oc_id
            AND mr.macro_id = 33
        WHERE ae1.ocorrencia_id = oc.ocorrencia_id
          AND ae1.atribuicao_oc_id = (SELECT MAX(atribuicao_oc_id)
                                      FROM operacao.atribui_oc_emergencial ae2
                                      WHERE ae2.atribuicao_oc_id = ae1.atribuicao_oc_id
                                      GROUP BY ae2.atribuicao_oc_id)) AS latitude,
       (SELECT MAX(mr.longitude)
        FROM operacao.atribui_oc_emergencial ae1
                 LEFT JOIN operacao.atribui_oc_mensagem_retorno mr ON mr.atribuicao_oc_id = ae1.atribuicao_oc_id
            AND mr.macro_id = 33
        WHERE ae1.ocorrencia_id = oc.ocorrencia_id
          AND ae1.atribuicao_oc_id = (SELECT MAX(atribuicao_oc_id)
                                      FROM operacao.atribui_oc_emergencial ae2
                                      WHERE ae2.atribuicao_oc_id = ae1.atribuicao_oc_id
                                      GROUP BY ae2.atribuicao_oc_id)) AS longitude,
       (SELECT rtrim(XMLAGG(xmlelement(e, wm_concat(mao.mat_ut_quantidade
           || ' - '
           || mat.mma_descricao
           || ';'), ';').extract('//text()')), ';')
        FROM operacao.material_utilizado_os mao
                 INNER JOIN operacao.material_manutencao mat ON mat.material_manutencao_id = mao.material_manutencao_id
        WHERE mao.hist_os_turma_id = ot.hist_turma_plantao_id
--AND MAT.MATERIAL_MANUTENCAO_ID NOT IN ('0,00','1,00')
        GROUP BY mao.hist_os_turma_id)                                   material_aplicado,
       --  mr.longitude,
       oc.se_id
           || '-'
           || oc.al_id                                                   se_alim,
       br.bai_nome                                                       bairro,
       'NR'                                                              tipo_ss,
       --oc.tb_tp_abrangencia
       DECODE(oc.tb_tp_abrangencia, 'CR', 'CONSUMIDOR', 'TF', 'TRANSFORMADOR', 'CH', 'CHAVE', 'AL', 'ALIMENTADOR', 'SE',
              'SUBESTACAO'
           , oc.tb_tp_abrangencia)                                       abrangencia,
       ot.hot_km_inicial                                                 km_inicial,
       ot.hot_km_final                                                   km_final,
       CASE
           WHEN oc.oco_qtd_rechamadas = 0 THEN
               1
           ELSE
               oc.oco_qtd_rechamadas
           END                                                           qtd_atribuicoes,
       0                                                                 qtd_faturas_corte,
       0                                                                 vlr_total_faturas_corte,
       0                                                                 qtd_faturas_uc,
       0                                                                 vlr_total_faturas_uc,
       'L'                                                               situacao_uc,
       TO_CHAR(oc.oco_data_nr, 'DD')                                     dia_sem_conc,
       'SEM_0'
           || TO_CHAR(oc.oco_data_nr, 'w')                               semana_mes_conc,
       TO_CHAR(oc.oco_data_nr, 'DY')                                     semana_mes_abrev,
       TO_CHAR(oc.oco_data_nr, 'MM')                                  AS "MES_CONCL",
       TO_CHAR(oc.oco_data_nr, 'MON')                                    mes_concl_abrev,
       TO_CHAR(oc.oco_data_nr, 'YYYY')                                AS "ANO_CONCL",
       (TO_CHAR(oc.oco_data_nr, 'MM'))
           || '/'
           || (TO_CHAR(oc.oco_data_nr, 'YYYY'))                       AS "MES_ANO",
       oc.ocorrencia_id                                                  os_oper,
       oc.oco_ano
           || '-'
           || oc.oco_mes
           || '/'
           || oc.oco_numero                                              os,
       'NR'                                                              ostipo,
       CASE
           WHEN oc.tb_tp_abrangencia = 'CR' THEN
               'IND'
           WHEN oc.tb_tp_abrangencia = 'NI' THEN
               'IND'
           ELSE
               'COL'
           END                                                           ossubtipo,
       mp.mnc_nome                                                       municipio,
       lo.loc_nome                                                       localidade,
       trunc(oc.cr_numero, 0)                                            uc,
       pt.prx_descricao                                                  prefixo,
       oc.oco_data_acionamento                                           atribuicao,
       oc.oco_hora_prevista                                              limite,
       CASE
           WHEN ot.hot_vi_data_conclusao <= oc.oco_hora_prevista THEN
               'DENTRO DO PRAZO'
           ELSE
               'FORA DO PRAZO'
           END                                                           status_prazo,
       --oc.oco_inf_adicionais
       oc.oco_observacoes_atendimento                                    registro_exec,
       TO_CHAR(oc.tb_causa_id)                                           cod_conclusao,
       tc.tca_descricao                                                  tipo_conclusao,
       CASE
           WHEN oc.tb_causa_id IN (
                                   2,
                                   4,
                                   6,
                                   7,
                                   8,
                                   9,
                                   10,
                                   11,
                                   12,
                                   14,
                                   15,
                                   16,
                                   17,
                                   18,
                                   19,
                                   20,
                                   27,
                                   34,
                                   39,
                                   50,
                                   56,
                                   59,
                                   73,
                                   74,
                                   89,
                                   90,
                                   92,
                                   96,
                                   98,
                                   99,
                                   100,
                                   101,
                                   118,
                                   148,
                                   149,
                                   150,
                                   151,
                                   252,
                                   262,
                                   273,
                                   274,
                                   276
               ) THEN
               'I'
           ELSE
               'P'
           END                                                           tipo,
       rg.rel_descricao                                                  regional,
       pa3.pap_nome                                                   AS base,
       --bs.bas_nome  BASE3,
       --  '' MATERIAL_APLICADO,
       oc.oco_data_nr                                                    data_origem,
       ot.hot_vi_data_aceite                                             inicio_deslocamento,
       ot.hot_vi_data_chegada                                            fim_deslocamento
-- , t.descricao MODALIDADE,
FROM operacao.ocorrencia oc
         INNER JOIN operacao.tipo_de_causa tc ON tc.tb_causa_id = oc.tb_causa_id
         INNER JOIN operacao.historico_ocorrencia_turma ot ON ot.ocorrencia_id = oc.ocorrencia_id
         INNER JOIN operacao.historico_turma_plantao tp ON tp.hist_turma_plantao_id = ot.hist_turma_plantao_id
         INNER JOIN operacao.prefixo_turma pt ON pt.prefixo_turma_id = tp.prefixo_turma_id
         INNER JOIN operacao.base bs ON bs.base_id = oc.base_id -- pt.base_id
         INNER JOIN operacao.ponto_apoio pa ON pa.codigo_pa = bs.codigo_pa
         INNER JOIN operacao.unidade_territorial ut ON ut.reg_eletrica_id = pa.reg_eletrica_id
         INNER JOIN operacao.regiao_eletrica rg ON rg.reg_eletrica_id = pa.reg_eletrica_id
         INNER JOIN operacao.bairro br ON br.bairro_id = oc.bairro_id
         INNER JOIN operacao.localidade lo ON lo.lc_id = br.lc_id
         INNER JOIN operacao.municipio mp ON mp.mnc_id = lo.mnc_id
         LEFT JOIN operacao.base bs3 ON bs3.base_id = mp.base_id
         INNER JOIN operacao.ponto_apoio pa3 ON pa3.codigo_pa = bs.codigo_pa
         LEFT JOIN operacao.code_medida t ON t.cdm_id = oc.tipo_conclusao
         LEFT JOIN operacao.instalacao_operacao io ON (oc.instalacao_id = io.instalacao_id)
WHERE oc.oco_status = 'F'
  AND ot.hot_vi_status = 4
  AND oc.oco_data_conclusao >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
--AND oc.oco_data_conclusao <> NULL

UNION ALL

SELECT 'EQTL PI' AS Empresa,
       atros_status,
       data_abertura,
       data_carga,
       processo,
       hora_entrada,
       oco_data_acionamento,
       hora_acionamento,
       host_vi_dt_ini_deslocamento,
       hora_aceite,
       host_vi_dt_fim_deslocamento,
       hora_chegada,
       dt_conclusao,
       hora_conclusao,
       equipamento,
       tmp,
       tmd,
       tma,
       tmt,
       latitude_exec,
       longitude_exec,
       material,
       se_alim,
       bairro,
       tipo_ss,
       abrangencia,
       km_inicial,
       km_final,
       qtd_atribuicoes,
       qtd_faturas_corte,
       vlr_total_faturas_corte,
       qtd_faturas_uc,
       vlr_total_faturas_uc,
       cd_situacao_uc,
       dia_sem_conc,
       semana_mes_conc,
       semana_mes_abrev,
       mes_concl,
       mes_concl_abrev,
       ano_concl,
       mes_ano,
       os_oper,
       os,
       ostipo_id,
       ossubtipo_id,
       municipio,
       localidade,
       uc,
       prefixo,
       atribuicao,
       limite,
       status_prazo,
       registro_exec,
       cod_conclusao,
       tipo_conclusao,
       CASE
           WHEN (cod_conclusao IS NULL
               AND atros_status = 'C') THEN
               'CANCELADA ATRIBUICAO - SOBRAS'
           WHEN (cod_conclusao IS NULL
               AND atros_status = 'E') THEN
               'ESPERA - POSSIVEL CANCELAMENTO AJURI'
           WHEN (cod_conclusao IS NULL
               AND atros_status = 'N') THEN
               'NAO EXECUTADO - FIM TURNO'
--then 'INCONSITENCIA_OPER'
           ELSE
               tipo
           END      tipo,
       regional,
       base,
       data_origem,
       inicio_deslocamento,
       fim_deslocamento
FROM (SELECT TO_CHAR(os.dt_programacao_os, 'DD/MM/YYYY')                                                     data_abertura,
             ac.atros_status,
             -- AC.*,-- E.ELE_NOME ELETRICISTA,
             SYSDATE                                                                                         data_carga,
             CASE
                 WHEN os.sstipo_id IN (
                                       'RI',
                                       'CT'
                     ) THEN
                     'CORTE_RELIGACAO'
                 WHEN os.sstipo_id IN (
                     'LG'
                     ) THEN
                     'LIGACAO_NOVA'
                 ELSE
                     'VERIF'
                 END                                                                                         processo,
             TO_CHAR(os.dt_programacao_os, 'HH24:MI:SS')                    AS                               hora_entrada,
             ac.atros_data                                                                                   oco_data_acionamento,
             TO_CHAR(ac.atros_data, 'HH24:MI:SS')                           AS                               hora_acionamento,
             tc.host_vi_dt_ini_deslocamento,
             TO_CHAR(tc.host_vi_dt_ini_deslocamento, 'HH24:MI:SS')          AS                               hora_aceite,
             tc.host_vi_dt_fim_deslocamento,
             TO_CHAR(tc.host_vi_dt_fim_deslocamento, 'HH24:MI:SS')          AS                               hora_chegada,
             cc.dt_conclusao,
             TO_CHAR(cc.dt_conclusao, 'HH24:MI:SS')                         AS                               hora_conclusao,
             '-'                                                                                             equipamento,
             round((ac.atros_data - os.dt_solicitacao) * 24, 3)                                              tmp,
             round((tc.host_vi_dt_fim_deslocamento - tc.host_vi_dt_ini_deslocamento) * 24, 3)                tmd,
             round((tc.host_vi_dt_fim_servico - tc.host_vi_dt_ini_servico) * 24, 3)                          tma,
             (round((ac.atros_data - os.dt_solicitacao) * 24, 3) * 24 +
              round((tc.host_vi_dt_fim_deslocamento - tc.host_vi_dt_ini_deslocamento
                        ) * 24, 3) + round((tc.host_vi_dt_ini_servico - tc.host_vi_dt_fim_servico) * 24, 3)) tmt,
             (SELECT MAX(mr.latitude)
              FROM operacao.atribui_os_comercial ae1
                       LEFT JOIN operacao.atribui_os_mensagem_retorno mr ON mr.atribuicao_os_id = ae1.atribuicao_os_id
                  AND mr.macro_id = 59
              WHERE ae1.cd_movto_os_comercial = os.cd_movto_os_comercial
                AND ae1.atribuicao_os_id = (SELECT MAX(atribuicao_os_id)
                                            FROM operacao.atribui_os_comercial ae2
                                            WHERE ae2.atribuicao_os_id = ae1.atribuicao_os_id
                                            GROUP BY ae2.atribuicao_os_id)) AS                               latitude_exec,
             (SELECT MAX(mr.longitude)
              FROM operacao.atribui_os_comercial ae1
                       LEFT JOIN operacao.atribui_os_mensagem_retorno mr ON mr.atribuicao_os_id = ae1.atribuicao_os_id
                  AND mr.macro_id = 59
              WHERE ae1.cd_movto_os_comercial = os.cd_movto_os_comercial
                AND ae1.atribuicao_os_id = (SELECT MAX(atribuicao_os_id)
                                            FROM operacao.atribui_os_comercial ae2
                                            WHERE ae2.atribuicao_os_id = ae1.atribuicao_os_id
                                            GROUP BY ae2.atribuicao_os_id)) AS                               longitude_exec,
             (SELECT rtrim(XMLAGG(xmlelement(e, wm_concat(mao.mat_ut_quantidade
                 || ' - '
                 || mat.mma_descricao), ';').extract('//text()')), ';')
              FROM operacao.material_utilizado_os mao
                       INNER JOIN operacao.material_manutencao mat
                                  ON mat.material_manutencao_id = mao.material_manutencao_id
              WHERE mao.hist_os_turma_id = tc.hist_os_turma_id
                AND mat.material_manutencao_id NOT IN (
                                                       0,
                                                       1
                  )
              GROUP BY mao.hist_os_turma_id)                                                                 material,


             --CASE WHEN OS.DS_OBS_ATENDENTE LIKE ('%JPMM%') THEN 'SIM' ELSE 'NAO' END
             '-'                                                                                             se_alim,
             br.bai_nome                                                                                     bairro,
             os.sstipo_id                                                                                    tipo_ss,
             'OS_COMERCIAL'                                                                                  abrangencia,
             --  OS.DS_OBS_ATENDENTE OBS_ABERTURA,
          /*CC.DS_REGISTRO_ATENDIMENTO APT_CAMPO,
         OS.TAXA_ATRASO EUSD,
        case when  ( (CC.DT_CONCLUSAO - OS.DT_LIMITE_EXECUCAO_OS)* OS.TAXA_ATRASO) <= 0 then 0
        else  ( (CC.DT_CONCLUSAO - OS.DT_LIMITE_EXECUCAO_OS)* OS.TAXA_ATRASO)
         end
         MULTA_PRAZO,
         cc.cd_zona_trafo trafo_inf,
         cc.nr_poste poste_inf,
            os.tipo_viatura_corte MODALIDADE,*/
             tc.host_km_inicial                                                                              km_inicial,
             tc.host_km_final                                                                                km_final,
             os.qtd_atribuicoes                                                                              qtd_atribuicoes,
             (os.qtd_faturas_corte)                                         AS                               qtd_faturas_corte,
             (os.vlr_total_faturas_corte)                                                                    vlr_total_faturas_corte,
             (os.qtd_faturas_uc)                                                                             qtd_faturas_uc,
             (os.vlr_total_faturas_uc)                                                                       vlr_total_faturas_uc,
             --OS.CD_TP_LOCAL_UC,
             --  OS.NM_CLIENTE,
             os.cd_situacao_uc,
             TO_CHAR(os.dt_programacao_os, 'DD')                                                             dia_sem_conc,
             'SEM_0'
                 ||
             TO_CHAR(os.dt_programacao_os, 'w')                                                              semana_mes_conc,
             TO_CHAR(os.dt_programacao_os, 'DY')                                                             semana_mes_abrev,
             TO_CHAR(os.dt_programacao_os, 'MM')                            AS                               "MES_CONCL",
             TO_CHAR(os.dt_programacao_os, 'MON')                                                            mes_concl_abrev,
             TO_CHAR(os.dt_programacao_os, 'YYYY')                          AS                               "ANO_CONCL",
             (TO_CHAR(os.dt_programacao_os, 'MM'))
                 || '/'
                 || (TO_CHAR(os.dt_programacao_os, 'YYYY'))                 AS                               "MES_ANO",
             os.cd_movto_os_comercial                                                                        os_oper,
             (TO_CHAR(os.dt_programacao_os, 'MM'))
                 || '/'
                 || (TO_CHAR(os.dt_programacao_os, 'YYYY'))
                 || '-'
                 || os.nr_os                                                                                 os,
             os.ostipo_id,
             os.ossubtipo_id,
             mp.mnc_nome                                                                                     municipio,
             lo.loc_nome                                                                                     localidade,
             trunc(os.nr_uc, 0)                                             AS                               uc,
             pt.prx_descricao                                               AS                               prefixo,
             ac.atros_data                                                                                   atribuicao,
             --CC.DT_CONCLUSAO conclusao2,
             --  to_char(CC.DT_CONCLUSAO, 'mm/dd/yyyy') conclusao,
             os.dt_limite_execucao_os                                                                        limite,
             ---------------------------------------------------------
             CASE
                 WHEN (os.ostipo_id = 'RI'
                     AND cc.dt_conclusao > os.dt_limite_execucao_os) THEN
                     'FORA DO PRAZO'
                 WHEN (os.ostipo_id = 'RI'
                     AND cc.dt_conclusao < os.dt_limite_execucao_os) THEN
                     'DENTRO DO PRAZO'
                 WHEN (os.ostipo_id <> 'RI '
                     AND TO_CHAR(cc.dt_conclusao, 'mm/dd/yyyy') > TO_CHAR(os.dt_limite_execucao_os, 'mm/dd/yyyy')) THEN
                     'FORA DO PRAZO'
                 WHEN (os.ostipo_id <> 'RI '
                     AND TO_CHAR(cc.dt_conclusao, 'mm/dd/yyyy') <= TO_CHAR(os.dt_limite_execucao_os, 'mm/dd/yyyy')) THEN
                     'DENTRO DO PRAZO'
                 END                                                                                         status_prazo,
             ---------------------------------------------------------


          /*  (SELECT mr.descricao
              FROM OPERACAO.MOTIVO_CANCELAMENTO_REJEICAO mr
               WHERE mr.MOT_CANCEL_REJ_ID= CD_MOTIVO_REJEICAO_CANCELA) */
             cc.ds_registro_atendimento                                                                      registro_exec,
             CASE
                 WHEN (os.ostipo_id = 'CT'
                     AND oc.tpoco_corte_id IS NOT NULL) THEN
                     cc.cd_tp_conclusao_os--oc.tpoco_corte_id
                 ELSE
                     (cc.cd_tp_conclusao_os)
                 END                                                                                         cod_conclusao,
             CASE
                 WHEN (cc.cd_tp_conclusao_os = '000'
                     AND os.sssubtipo_id = 'VIS') THEN
                     'EXECUÇÃO DA VISTORIA'
                 WHEN (cc.cd_tp_conclusao_os = '003'
                     AND os.ossubtipo_id = 'VIS') THEN
                     'SEM REDE E CLIENTE ACEITA FINANCIAMENTO'
                 WHEN (cc.cd_tp_conclusao_os = '004'
                     AND os.sssubtipo_id = 'VIS') THEN
                     'SEM REDE E UC JA POSSUI PADRAO'
                 WHEN (cc.cd_tp_conclusao_os = '000'
                     AND os.ostipo_id = 'LG'
                     AND os.sssubtipo_id <> 'VIS') THEN
                     'CONCLUSÃO NORMAL'
                 WHEN (os.ostipo_id = 'CT'
                     AND oc.tpoco_corte_id IS NOT NULL) THEN
                     cm.descricao--oc.descricao_tpoco_corte

             -- WHEN OS.OSTIPO_ID = 'RI' AND
             --       CC.CD_TP_CONCLUSAO_OS in ('0001','0002','0003','0004','0005','0012','0013','0014','0015','0018','0019')
             --    THEN LREL.LCRELIG_DESCRICAO
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0096' THEN
                     'RELIGAÇÃO IMPEDIDA/NÃO APRESE CONTA PAGA'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0095' THEN
                     'RELIGAÇÃO IMPEDIDA/AUTO RELIGADO'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0021' THEN
                     'UC FORA DE PADRAO OU INCOMPLETO'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0017' THEN
                     'OUTROS'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0015' THEN
                     'NÃO APRESENTOU FATURAS PAGAS'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0011' THEN
                     'NÃO LOCALIZADO'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0009' THEN
                     'OBSTÁCULO IMPEDE A EXECUÇÃO - SEM ACESSO'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0006' THEN
                     'CASA FECHADA-SEM ACESSO AO DISJUNTOR'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0002' THEN
                     'NÃO EXECUTADO'
                 WHEN os.ostipo_id = 'RI'
                     AND cc.cd_tp_conclusao_os = '0001' THEN
                     lrel.lcrelig_descricao

                 --CC.CD_TP_CONCLUSAO_OS NOT in ('0001','0002','0003','0004','0005','0012','0013','0014','0015','0018','0019')
                 --  THEN CM.DESCRICAO
                 WHEN (os.ostipo_id = 'CT'
                     AND oc.tpoco_corte_id IS NULL) THEN
                     cm.descricao
                 WHEN cc.cd_tp_conclusao_os = '999' THEN
                     'RECUSA DE SERVIÇO'
                 WHEN (atros_status = 'C'
                     AND cc.dt_conclusao IS NULL) THEN
                     'SOBRAS' --PT.PRX_DESCRICAO = 'COM1010' THEN 'SOBRAS EQUIPE COM1010'
                 ELSE
                     cm.descricao
                 END                                                                                         tipo_conclusao,


          /* (SELECT mr.CD_MOT_CANCEL_REJ
              FROM OPERACAO.MOTIVO_CANCELAMENTO_REJEICAO mr
               WHERE mr.MOT_CANCEL_REJ_ID = CD_MOTIVO_REJEICAO_CANCELA)  motivo_rejeicao,
               */
             (
                 CASE
                     WHEN (cc.cd_tp_conclusao_os IN (
                                                     1,
                                                     3,
                                                     4,
                                                     5,
                                                     6,
                                                     7,
                                                     9,
                                                     19,
                                                     23
                         )
                         AND os.ostipo_id = 'CT') THEN
                         'P'
                     WHEN (cc.cd_tp_conclusao_os IN (
                                                     2,
                                                     10,
                                                     11,
                                                     12,
                                                     13,
                                                     14,
                                                     15,
                                                     16,
                                                     17,
                                                     20,
                                                     22,
                                                     24.34
                         )
                         AND os.ostipo_id = 'CT') THEN
                         'I'
                     WHEN (cc.cd_tp_conclusao_os IN (
                                                     14,
                                                     18,
                                                     21
                         )
                         AND os.ostipo_id = 'CT') THEN
                         ''
                     WHEN cc.cd_tp_conclusao_os = '999' THEN
                         'I'
                     WHEN (cm.tipo_conclusao = 'R'
                         AND cm.code_medida_id NOT IN (
                             '0017'
                             )
                         AND cc.cd_tp_conclusao_os <> '0023') THEN
                         'I'
                     WHEN (cm.tipo_conclusao = 'R'
                         AND cm.code_medida_id = '0017') THEN
                         'I'--incluido cancelamento como improdutivo
                     WHEN (cm.tipo_conclusao = 'R'
                         AND cc.cd_tp_conclusao_os = '0023'
                         AND os.ostipo_id = 'CT') THEN
                         'P'--Negociacao Seed Money
                     WHEN cm.tipo_conclusao = 'N' THEN
                         'P'
                     /*-- WHEN PT.PRX_DESCRICAO = 'COM1010' THEN 'I-SOBRAS'
                      WHEN (AC.ATROS_STATUS = 'C' ) THEN 'CANCELADO-SOBRAS'*/
                     ELSE
                         'I'
                     END
                 )                                                                                           tipo,
             rg.rel_descricao                                                                                regional,
             pa3.pap_nome                                                   AS                               base,
             os.dt_solicitacao                                                                               data_origem,
             tc.host_vi_dt_ini_deslocamento                                                                  inicio_deslocamento,
             tc.host_vi_dt_fim_deslocamento                                                                  fim_deslocamento,
             ROW_NUMBER() OVER (
                 PARTITION BY os.cd_movto_os_comercial
                 ORDER BY
                     cm.tipo_conclusao
                 )                                                          AS                               rn
      FROM operacao.movto_os_comercial os
               LEFT OUTER JOIN operacao.bairro br ON br.bairro_id = os.cd_bairro
               LEFT OUTER JOIN operacao.localidade lo ON lo.lc_id = br.lc_id
               LEFT OUTER JOIN operacao.municipio mp ON mp.mnc_id = lo.mnc_id
               LEFT OUTER JOIN operacao.conclui_os_comercial cc ON cc.cd_movto_os_comercial = os.cd_movto_os_comercial
               LEFT OUTER JOIN operacao.tipo_ocorrencia_corte oc ON oc.tpoco_corte_id = cc.cd_tp_ocorrencia_corte
               LEFT OUTER JOIN operacao.atribui_os_comercial ac ON ac.cd_movto_os_comercial = os.cd_movto_os_comercial
               LEFT OUTER JOIN operacao.prefixo_turma pt ON pt.prefixo_turma_id = ac.prefixo_turma_id
               LEFT OUTER JOIN operacao.turma_os_comercial tc ON tc.atribuicao_os_id = ac.atribuicao_os_id
               LEFT OUTER JOIN operacao.base bs ON bs.base_id = br.base_id
               LEFT OUTER JOIN operacao.ponto_apoio pa ON pa.codigo_pa = bs.codigo_pa
               LEFT OUTER JOIN operacao.regiao_eletrica rg ON rg.reg_eletrica_id = pa.reg_eletrica_id
               LEFT OUTER JOIN operacao.tipo_os_local_religacao lr ON lr.tb_lcrelig_id = cc.cd_local_religacao
               LEFT OUTER JOIN operacao.base bs3 ON bs3.base_id = mp.base_id
               LEFT OUTER JOIN operacao.ponto_apoio pa3 ON pa3.codigo_pa = bs.codigo_pa
               LEFT OUTER JOIN operacao.code_medida cm ON cm.ossubtipo_id = os.ossubtipo_id
          AND cc.cd_tp_conclusao_os = cm.code_medida_id
               LEFT OUTER JOIN operacao.tipo_os_local_religacao lrel ON lrel.tb_lcrelig_id = cc.cd_local_religacao
      WHERE cc.dt_conclusao >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
        -- AND  cc.dt_conclusao <> NULL
        -- AND OS.NR_OS = '26745284'
        --  AND AC.ATROS_STATUS = 'C'
        AND ac.atribuicao_os_id = (SELECT MAX(ac2.atribuicao_os_id)
                                   FROM operacao.atribui_os_comercial ac2
                                   WHERE ac2.cd_movto_os_comercial = ac.cd_movto_os_comercial
                                   GROUP BY ac2.cd_movto_os_comercial)
         --  and  (cc.cd_tp_conclusao_os is not null)
     ) xx
WHERE rn = 1
