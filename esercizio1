-- Analisi delle prestazioni per cluster di ASL con correlazioni
WITH asl_metrics AS (
    SELECT 
        `ASL assistito`,
        COUNT(*) as prestazioni_totali,
        AVG(`importo (euro)`) as costo_medio,
        SUM(`importo (euro)`) as spesa_totale,
        COUNT(DISTINCT `comune assistito`) as comuni_coperti,
        COUNT(DISTINCT `disciplina erogatore`) as specializzazioni,
        -- Calcola età media ponderata
        SUM(`classe età` * `numero prestazione`) / SUM(`numero prestazione`) as eta_media_ponderata
    FROM healthcare_data
    WHERE `ASL assistito` IS NOT NULL
    GROUP BY `ASL assistito`
),
asl_percentili AS (
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY spesa_totale) as percentile_spesa,
        PERCENT_RANK() OVER (ORDER BY costo_medio) as percentile_costo_medio
    FROM asl_metrics
)
SELECT 
    a1.`ASL assistito` as asl_principale,
    a2.`ASL assistito` as asl_confronto,
    ABS(a1.costo_medio - a2.costo_medio) as differenza_costo,
    ABS(a1.eta_media_ponderata - a2.eta_media_ponderata) as differenza_eta,
    CASE 
        WHEN ABS(a1.percentile_spesa - a2.percentile_spesa) < 0.1 
         AND ABS(a1.percentile_costo_medio - a2.percentile_costo_medio) < 0.1
        THEN 'CLUSTER_SIMILE'
        ELSE 'DIVERSO'
    END as tipo_relazione
FROM asl_percentili a1
JOIN asl_percentili a2 ON a1.`ASL assistito` < a2.`ASL assistito`
WHERE ABS(a1.percentile_spesa - a2.percentile_spesa) < 0.1 
   OR ABS(a1.percentile_costo_medio - a2.percentile_costo_medio) < 0.1
ORDER BY differenza_costo;
