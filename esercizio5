-- KPI dashboard con metriche di efficienza per stakeholder
WITH performance_metrics AS (
    SELECT 
        `azienda erogante`,
        `disciplina erogatore`,
        `branca ricetta`,
        -- Metriche di volume
        COUNT(DISTINCT Codice_Nosologico) as pazienti_unici,
        SUM(`numero prestazione`) as prestazioni_totali,
        COUNT(DISTINCT prestazione) as tipologie_prestazioni,
        
        -- Metriche economiche  
        SUM(`importo (euro)`) as ricavi_totali,
        AVG(`importo (euro)`) as ricavo_medio_prestazione,
        
        -- Metriche di efficienza
        SUM(`importo (euro)`) / COUNT(DISTINCT Codice_Nosologico) as costo_per_paziente,
        SUM(`numero prestazione`) / COUNT(DISTINCT Codice_Nosologico) as prestazioni_per_paziente,
        
        -- Metriche demografiche
        AVG(`classe età`) as eta_media_pazienti,
        COUNT(CASE WHEN sesso = 'F' THEN 1 END) * 100.0 / COUNT(*) as percentuale_femmine
    FROM healthcare_data
    GROUP BY `azienda erogante`, `disciplina erogatore`, `branca ricetta`
    HAVING pazienti_unici >= 5
),
benchmarks AS (
    SELECT 
        `disciplina erogatore`,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY costo_per_paziente) as mediana_costo_paziente,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY prestazioni_per_paziente) as q3_prestazioni_paziente,
        AVG(ricavo_medio_prestazione) as benchmark_ricavo_medio
    FROM performance_metrics
    GROUP BY `disciplina erogatore`
)
SELECT 
    pm.*,
    b.mediana_costo_paziente,
    b.q3_prestazioni_paziente,
    CASE 
        WHEN pm.costo_per_paziente > b.mediana_costo_paziente * 1.5 THEN 'ALTO_COSTO'
        WHEN pm.prestazioni_per_paziente > b.q3_prestazioni_paziente * 1.2 THEN 'ALTO_VOLUME'
        WHEN pm.ricavo_medio_prestazione > b.benchmark_ricavo_medio * 1.3 THEN 'ALTO_VALORE'
        ELSE 'STANDARD'
    END as categoria_performance,
    -- Score di efficienza complessiva
    (
        (1.0 / (1 + pm.costo_per_paziente / b.mediana_costo_paziente)) * 0.4 +
        (pm.prestazioni_per_paziente / b.q3_prestazioni_paziente) * 0.3 +
        (pm.ricavo_medio_prestazione / b.benchmark_ricavo_medio) * 0.3
    ) as efficiency_score
FROM performance_metrics pm
JOIN benchmarks b ON pm.`disciplina erogatore` = b.`disciplina erogatore`
ORDER BY efficiency_score DESC;
