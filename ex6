-- Modello di forecast per allocazione risorse sanitarie
WITH seasonal_patterns AS (
    SELECT 
        `disciplina erogatore`,
        mese,
        AVG(monthly_volume) as volume_medio_stagionale,
        AVG(monthly_cost) as costo_medio_stagionale,
        STDDEV(monthly_volume) as volatilità_volume
    FROM (
        SELECT 
            `disciplina erogatore`,
            Anno,
            mese,
            COUNT(*) as monthly_volume,
            SUM(`importo (euro)`) as monthly_cost
        FROM healthcare_data
        WHERE `disciplina erogatore` IS NOT NULL
        GROUP BY `disciplina erogatore`, Anno, mese
    ) monthly_data
    GROUP BY `disciplina erogatore`, mese
),
growth_trends AS (
    SELECT 
        `disciplina erogatore`,
        -- Calcolo del trend di crescita lineare
        (
            COUNT(*) * SUM(periodo_numerico * volume_mensile) - 
            SUM(periodo_numerico) * SUM(volume_mensile)
        ) / NULLIF(
            COUNT(*) * SUM(periodo_numerico * periodo_numerico) - 
            SUM(periodo_numerico) * SUM(periodo_numerico), 0
        ) as crescita_mensile
    FROM (
        SELECT 
            `disciplina erogatore`,
            (Anno - 2004) * 12 + mese as periodo_numerico,
            COUNT(*) as volume_mensile
        FROM healthcare_data
        WHERE `disciplina erogatore` IS NOT NULL
        GROUP BY `disciplina erogatore`, Anno, mese
    ) trend_data
    GROUP BY `disciplina erogatore`
)
SELECT 
    sp.`disciplina erogatore`,
    sp.mese,
    sp.volume_medio_stagionale,
    sp.costo_medio_stagionale,
    sp.volatilità_volume,
    gt.crescita_mensile,
    -- Forecast per il mese successivo
    sp.volume_medio_stagionale * (1 + COALESCE(gt.crescita_mensile, 0)) as forecast_volume,
    sp.costo_medio_stagionale * (1 + COALESCE(gt.crescita_mensile, 0)) as forecast_costo,
    -- Intervallo di confidenza
    sp.volume_medio_stag
