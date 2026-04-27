-- Analisi predittiva della spesa basata su caratteristiche demografiche
WITH monthly_cohorts AS (
    SELECT 
        Anno,
        mese,
        `classe età`,
        sesso,
        `branca ricetta`,
        COUNT(*) as popolazione_coorte,
        AVG(`importo (euro)`) as spesa_media_per_persona,
        SUM(`numero prestazione`) as volume_prestazioni,
        COUNT(DISTINCT prestazione) as diversità_prestazioni
    FROM healthcare_data
    WHERE sesso IN ('M', 'F') AND `classe età` BETWEEN 1 AND 21
    GROUP BY Anno, mese, `classe età`, sesso, `branca ricetta`
    HAVING popolazione_coorte >= 3
),
regression_features AS (
    SELECT *,
        -- Features per modello predittivo
        `classe età` * volume_prestazioni as eta_per_volume,
        diversità_prestazioni / popolazione_coorte as diversità_normalizzata,
        CASE WHEN sesso = 'M' THEN 1 ELSE 0 END as maschio_dummy,
        ROW_NUMBER() OVER (
            PARTITION BY `classe età`, sesso 
            ORDER BY spesa_media_per_persona DESC
        ) as rank_spesa_per_coorte
    FROM monthly_cohorts
),
correlation_analysis AS (
    SELECT 
        `branca ricetta`,
        -- Correlazione approssimata tra età e spesa
        (
            COUNT(*) * SUM(`classe età` * spesa_media_per_persona) - 
            SUM(`classe età`) * SUM(spesa_media_per_persona)
        ) / SQRT(
            (COUNT(*) * SUM(`classe età` * `classe età`) - SUM(`classe età`) * SUM(`classe età`)) *
            (COUNT(*) * SUM(spesa_media_per_persona * spesa_media_per_persona) - SUM(spesa_media_per_persona) * SUM(spesa_media_per_persona))
        ) as correlazione_eta_spesa,
        AVG(CASE WHEN maschio_dummy = 1 THEN spesa_media_per_persona END) as spesa_media_maschi,
        AVG(CASE WHEN maschio_dummy = 0 THEN spesa_media_per_persona END) as spesa_media_femmine
    FROM regression_features
    GROUP BY `branca ricetta`
)
SELECT 
    rf.`branca ricetta`,
    rf.`classe età`,
    rf.sesso,
    rf.spesa_media_per_persona,
    ca.correlazione_eta_spesa,
    ca.spesa_media_maschi - ca.spesa_media_femmine as gap_genere,
    -- Predizione semplificata
    CASE 
        WHEN ca.correlazione_eta_spesa > 0.5 THEN 
            rf.spesa_media_per_persona * (1 + ca.correlazione_eta_spesa * 0.1)
        ELSE rf.spesa_media_per_persona
    END as spesa_predetta_prossimo_periodo
FROM regression_features rf
JOIN correlation_analysis ca ON rf.`branca ricetta` = ca.`branca ricetta`
WHERE rf.rank_spesa_per_coorte <= 3
ORDER BY rf.`branca ricetta`, rf.spesa_media_per_persona DESC;
