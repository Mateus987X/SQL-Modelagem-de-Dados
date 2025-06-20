/-- Query para calcular horas trabalhadas a partir de marcações de ponto
-- Considera as marcações de ponto, calcula as horas trabalhadas e ajusta erros de cálculo
-- caso sejam maiores que 10 horas.
-- A consulta final retorna os dados formatados e com as horas trabalhadas em segundos.
-- A consulta é baseada na tabela SP8010, que contém as marcações de ponto.
-- A consulta filtra as marcações a partir de 01/01/2023 e ignora motivos de rejeição automática e exclusão manual.


WITH Ponto AS (
    SELECT 
        CAST(P8_DATA AS varchar)  + '|' + FORMAT(P8_HORA, '00') ORDENADOR,
        P8_CC,
        P8_MOTIVRG,
        P8_MAT,
        P8_DATAAPO,
        P8_HORA,
        -- Convertendo P8_HORA para segundos
        (FLOOR(P8_HORA) * 3600) + ((P8_HORA - FLOOR(P8_HORA)) * 100 * 60) AS P8_HORA_SEGUNDOS,
        P8_FILIAL,
        P8_ORDEM,
        P8_TPMARCA,
        LAG((FLOOR(P8_HORA) * 3600) + ((P8_HORA - FLOOR(P8_HORA)) * 100 * 60)) 
            OVER (PARTITION BY P8_MAT, P8_DATAAPO ORDER BY CAST(P8_DATA AS varchar)  + '|' + FORMAT(P8_HORA, '00')) 
        AS Hora_Anterior_Segundos, -- Convertendo Hora_Anterior para segundos
        ROW_NUMBER() OVER (PARTITION BY P8_MAT, P8_DATAAPO ORDER BY CAST(P8_DATA AS varchar)  + '|' + FORMAT(P8_HORA, '00')) 
        AS Numero_Linha,
        COUNT(*) OVER (PARTITION BY P8_MAT, P8_DATAAPO) AS Total_Marcacoes
    FROM 
        SP8010
    WHERE 
        D_E_L_E_T_ = '' 
        AND P8_DATAAPO >= '20230101' 
        AND P8_MOTIVRG NOT IN ('REJEICAO AUTOMATICA', 'EXCLUSAO MANUAL')
),

Temp AS (
    SELECT 
        ORDENADOR,
        P8_CC,
        P8_MOTIVRG,
        P8_FILIAL,
        P8_MAT,
        P8_DATAAPO,
        P8_HORA,
        P8_HORA_SEGUNDOS,
        Hora_Anterior_Segundos,
        -- Cálculo correto de horas trabalhadas usando segundos
        CASE 
            WHEN P8_HORA_SEGUNDOS < Hora_Anterior_Segundos 
            THEN Hora_Anterior_Segundos - P8_HORA_SEGUNDOS
            ELSE P8_HORA_SEGUNDOS - Hora_Anterior_Segundos
        END AS HORAS_TRABALHADAS_SEGUNDOS,
        P8_ORDEM,
        P8_TPMARCA,
        Numero_Linha,
        Total_Marcacoes
    FROM Ponto
),

Temp2 AS (
    SELECT 
        ORDENADOR,
        P8_CC,
        P8_FILIAL,
        P8_MOTIVRG,
        P8_MAT,
        P8_DATAAPO,
        P8_HORA,
        P8_HORA_SEGUNDOS,
        Hora_Anterior_Segundos,
        -- Ajustando erro de cálculo caso seja maior que 10 horas (convertido para segundos)
        CASE 
            WHEN HORAS_TRABALHADAS_SEGUNDOS > (10 * 3600) 
            THEN (24 * 3600) - HORAS_TRABALHADAS_SEGUNDOS 
            ELSE HORAS_TRABALHADAS_SEGUNDOS 
        END AS HORAS_TRABALHADAS_SEGUNDOS,
        P8_ORDEM,
        P8_TPMARCA,
        Numero_Linha,
        Total_Marcacoes
    FROM Temp
)

SELECT 
    P8_CC,
    P8_MAT,
    P8_DATAAPO, 
    P8_FILIAL,
    P8_HORA, -- Mantendo o formato original
    P8_HORA_SEGUNDOS, -- Agora em segundos
    Hora_Anterior_Segundos, -- Agora em segundos
    HORAS_TRABALHADAS_SEGUNDOS, -- Agora em segundos
    P8_ORDEM,
    Numero_Linha,
    CASE
        WHEN Numero_Linha % 2 = 0 THEN 'DENTRO'
        WHEN Numero_Linha = 1 THEN 'INICIO'
        ELSE 'FORA'
    END AS STATUS,
    Total_Marcacoes,
    P8_FILIAL + '|' + P8_MAT AS FK_MAT,
    ORDENADOR,
    P8_MOTIVRG
FROM Temp2
WHERE 
     Total_Marcacoes <  5

   
