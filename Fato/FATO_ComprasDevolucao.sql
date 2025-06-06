SELECT 
    'P |01|01' AS BK_EMPRESA,
    CASE 
        WHEN D2_FILIAL IS NULL THEN 'P |01||' 
        ELSE 'P |01|01' + CAST(D2_FILIAL AS CHAR(6)) 
    END AS BK_FILIAL,
    'P |01|SA2010|' + COALESCE(NULLIF(RTRIM(COALESCE(A2_FILIAL, ' ')) + '|' + RTRIM(COALESCE(D2_CLIENTE, ' ')) + RTRIM(COALESCE(D2_LOJA, ' ')), ' '), '|') AS BK_FORNECEDOR,
    'P |01|CTT010|' + COALESCE(NULLIF(RTRIM(COALESCE(CTT_FILIAL, ' ')) + '|' + RTRIM(COALESCE(D1_CC, ' ')), ' '), '|') AS BK_CENTRO_DE_CUSTO,
    'P |01|SF4010|' + COALESCE(NULLIF(RTRIM(COALESCE(F4_FILIAL, ' ')) + '|' + RTRIM(COALESCE(D2_TES, ' ')), ' '), '|') AS BK_TES,
    'P |01|SB1010|' + COALESCE(NULLIF(RTRIM(COALESCE(B1_FILIAL, ' ')) + '|' + RTRIM(COALESCE(D2_COD, ' ')), ' '), '|') AS BK_ITEM,
    'P |01|SAH010|' + COALESCE(NULLIF(RTRIM(COALESCE(AH_FILIAL, ' ')) + '|' + RTRIM(COALESCE(D2_UM, ' ')), ' '), '|') AS BK_UNIDADE_DE_MEDIDA,
    'P |01|SE4010|' + COALESCE(NULLIF(RTRIM(COALESCE(E4_FILIAL, ' ')) + '|' + RTRIM(COALESCE(F1_COND, ' ')), ' '), '|') AS BK_CONDICAO_DE_PAGAMENTO,
    'P |01|ACU010|' + COALESCE(NULLIF(RTRIM(COALESCE(ACU_FILIAL, ' ')) + '|' + RTRIM(COALESCE(ACV_CATEGO, ' ')), ' '), '|') AS BK_FAMILIA_COMERCIAL,
    'P |01|SX5010|' + COALESCE(NULLIF(RTRIM(COALESCE(FAMAT.X5_FILIAL, ' ')) + '|' + RTRIM(COALESCE(B1_TIPO, ' ')), ' '), '|') AS BK_FAMILIA_MATERIAL,
    'P |01|SBM010|' + COALESCE(NULLIF(RTRIM(COALESCE(BM_FILIAL, ' ')) + '|' + RTRIM(COALESCE(B1_GRUPO, ' ')), ' '), '|') AS BK_GRUPO_ESTOQUE,
    'P |01|SA4010|' + COALESCE(NULLIF(RTRIM(COALESCE(A4_FILIAL, ' ')) + '|' + RTRIM(COALESCE(F1_TRANSP, ' ')), ' '), '|') AS BK_TRANSPORTADORA,
    'P |' + COALESCE(NULLIF(RTRIM(COALESCE('D', ' ')), ' '), '|') AS BK_SITUACAO_COMPRA,
    'P |01|SX5010|' + COALESCE(NULLIF(RTRIM(COALESCE(GRPFOR.X5_FILIAL, ' ')) + '|' + RTRIM(COALESCE(A2_GRUPO, ' ')), ' '), '|') AS BK_GRUPO_FORNECEDOR,
    CASE 
        WHEN A2_COD_MUN = ' ' THEN 'P |01|CC2010|' + COALESCE(NULLIF(RTRIM(COALESCE(A2_EST, ' ')), ' '), '|')
        ELSE 'P |01|CC2010|' + COALESCE(NULLIF(RTRIM(COALESCE(A2_EST, ' ')) + RTRIM(COALESCE(A2_COD_MUN, ' ')), ' '), '|') 
    END AS BK_REGIAO,
    D2_DOC AS NUMERO_NOTA_FISCAL,
    D2_SERIE AS SERIE_NOTA_FISCAL,
    D2_EMISSAO AS DATA_DA_EMISSAO,
    D1_PEDIDO AS NUMERO_PEDIDO,
    D1_ITEMPC AS ITEM_PEDIDO,
    D2_QUANT AS QUANTIDADE_DEVOLVIDA,
    D2_TOTAL AS VALOR_DEVOLVIDO,
    '01' AS INSTANCIA,
    'P |01|SM2010|' + COALESCE(RIGHT('00' + CAST(F1_MOEDA AS VARCHAR(2)), 2), '|') AS BK_MOEDA,
    COALESCE(F1_TXMOEDA, 0) AS TAXA_MOEDA
FROM 
    SD2010 SD2
    LEFT JOIN SA2010 SA2 ON A2_FILIAL = SUBSTRING(D2_FILIAL, 1, 2) 
        AND A2_COD = D2_CLIENTE 
        AND A2_LOJA = D2_LOJA 
        AND SA2.D_E_L_E_T_ = ' '
    LEFT JOIN SX5010 GRPFOR ON GRPFOR.X5_FILIAL = D2_FILIAL 
        AND GRPFOR.X5_TABELA = 'Y7' 
        AND GRPFOR.X5_CHAVE = A2_GRUPO 
        AND GRPFOR.D_E_L_E_T_ = ' '
    LEFT JOIN SB1010 SB1 ON B1_FILIAL = SUBSTRING(D2_FILIAL, 1, 2) 
        AND B1_COD = D2_COD 
        AND SB1.D_E_L_E_T_ = ' '
    LEFT JOIN SBM010 SBM ON BM_FILIAL = SUBSTRING(B1_FILIAL, 1, 2)
        AND BM_GRUPO = B1_GRUPO 
        AND SBM.D_E_L_E_T_ = ' '
    LEFT JOIN SX5010 FAMAT ON FAMAT.X5_FILIAL = D2_FILIAL 
        AND FAMAT.X5_TABELA = '02' 
        AND FAMAT.X5_CHAVE = B1_TIPO 
        AND FAMAT.D_E_L_E_T_ = ' '
    LEFT JOIN SAH010 SAH ON AH_FILIAL = SUBSTRING(D2_FILIAL, 1, 4) 
        AND AH_UNIMED = D2_UM 
        AND SAH.D_E_L_E_T_ = ' '
    LEFT JOIN ACV010 ACV ON ACV_FILIAL = SUBSTRING(D2_FILIAL, 1, 4) 
        AND ACV_CODPRO = D2_COD 
        AND ACV.D_E_L_E_T_ = ' '
    LEFT JOIN ACU010 ACU ON ACU_FILIAL = ACV_FILIAL 
        AND ACU_COD = ACV.ACV_CATEGO 
        AND ACU.D_E_L_E_T_ = ' '
    LEFT JOIN SD1010 SD1 ON D1_FILIAL = D2_FILIAL 
        AND D1_COD = D2_COD 
        AND D1_DOC = D2_NFORI 
        AND D1_SERIE = D2_SERIORI 
        AND D1_FORNECE = D2_CLIENTE 
        AND D1_LOJA = D2_LOJA 
        AND SD1.D_E_L_E_T_ = ' '
    LEFT JOIN CTT010 CTT ON CTT_FILIAL = SUBSTRING(D1_FILIAL, 1, 2) 
        AND CTT_CUSTO = D1_CC 
        AND CTT.D_E_L_E_T_ = ' '
    LEFT JOIN SF4010 SF4 ON F4_FILIAL = SUBSTRING(D2_FILIAL, 1, 2) 
        AND F4_CODIGO = D2_TES 
        AND SF4.D_E_L_E_T_ = ' '
    LEFT JOIN SF1010 SF1 ON F1_FILIAL = D2_FILIAL 
        AND F1_DOC = D2_NFORI 
        AND F1_SERIE = D2_SERIORI 
        AND F1_FORNECE = D2_CLIENTE 
        AND F1_LOJA = D2_LOJA 
        AND F1_TIPO = D2_TIPO 
        AND SF1.D_E_L_E_T_ = ' '
    LEFT JOIN SA4010 SA4 ON A4_FILIAL = SUBSTRING(F1_FILIAL, 1, 2) 
        AND A4_COD = F1_TRANSP 
        AND SA4.D_E_L_E_T_ = ' '
    LEFT JOIN SE4010 SE4 ON E4_FILIAL = SUBSTRING(F1_FILIAL, 1, 2) 
        AND E4_CODIGO = F1_COND 
        AND SE4.D_E_L_E_T_ = ' '
WHERE  
    SD2.D_E_L_E_T_ = ' '
    AND D2_TIPO = 'D' 
    AND D2_ORIGLAN <> 'LF' 
    AND D2_EMISSAO <= <<FINAL_DATE>>
