-- Individuazione di pattern anomali nei costi per disciplina
WITH disciplina_baseline AS (
    SELECT 
        `disciplina erogatore`,
        prestazione,
        COUNT(*) as frequenza,
        AVG(`importo (euro)`) as costo_medio,
        STDDEV(`importo (euro)`) as deviazione_std,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY `importo (euro)`) as mediana,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY `importo (euro)`) as p95
    FROM healthcare_data
    WHERE `disciplina erogatore` IS NOT NULL AND `importo (euro)` > 0
    GROUP BY `disciplina erogatore`, prestazione
    HAVING frequenza >= 3
),
anomalie AS (
    SELECT 
        hd.*,
        db.costo_medio as baseline_costo_medio,
        db.deviazione_std,
        db.mediana,
        ABS(hd.`importo (euro)` - db.costo_medio) / 
        NULLIF(db.deviazione_std, 0) as z_score,
        CASE 
            WHEN hd.`importo (euro)` > db.p95 * 2 THEN 'OUTLIER_ALTO'
            WHEN hd.`importo (euro)` < db.costo_medio * 0.1 THEN 'OUTLIER_BASSO'
            WHEN ABS(hd.`importo (euro)` - db.costo_medio) / 
                 NULLIF(db.deviazione_std, 0) > 3 THEN 'ANOMALIA_STATISTICA'
            ELSE 'NORMALE'
        END as tipo_anomalia
    FROM healthcare_data hd
    JOIN disciplina_baseline db ON 
        hd.`disciplina erogatore` = db.`disciplina erogatore` AND
        hd.prestazione = db.prestazione
)
SELECT 
    `disciplina erogatore`,
    prestazione,
    COUNT(*) as anomalie_totali,
    AVG(z_score) as z_score_medio,
    MAX(`importo (euro)`) as importo_max_anomalo,
    tipo_anomalia,
    STRING_AGG(`azienda erogante`, ', ') as aziende_coinvolte
FROM anomalie 
WHERE tipo_anomalia != 'NORMALE'
GROUP BY `disciplina erogatore`, prestazione, tipo_anomalia
HAVING anomalie_totali >= 2
ORDER BY z_score_medio DESC;
