-- Analisi di correlazione tra comuni per tipo di prestazioni
WITH comune_profilo AS (
    SELECT 
        `comune assistito`,
        `branca ricetta`,
        COUNT(*) as prestazioni,
        SUM(`importo (euro)`) as spesa_totale,
        AVG(`classe età`) as eta_media_utenti
    FROM healthcare_data
    GROUP BY `comune assistito`, `branca ricetta`
),
comune_pivot AS (
    SELECT 
        `comune assistito`,
        SUM(CASE WHEN `branca ricetta` = 2 THEN spesa_totale ELSE 0 END) as spesa_branca_2,
        SUM(CASE WHEN `branca ricetta` = 6 THEN spesa_totale ELSE 0 END) as spesa_branca_6,
        SUM(CASE WHEN `branca ricetta` = 11 THEN spesa_totale ELSE 0 END) as spesa_branca_11,
        SUM(CASE WHEN `branca ricetta` = 26 THEN spesa_totale ELSE 0 END) as spesa_branca_26,
        SUM(spesa_totale) as spesa_totale_comune,
        AVG(eta_media_utenti) as eta_media_ponderata
    FROM comune_profilo
    GROUP BY `comune assistito`
    HAVING spesa_totale_comune > 100
)
SELECT 
    c1.`comune assistito` as comune_a,
    c2.`comune assistito` as comune_b,
    -- Calcolo di similarità basato su distanza euclidea normalizzata
    SQRT(
        POWER((c1.spesa_branca_2 - c2.spesa_branca_2) / GREATEST(c1.spesa_totale_comune, c2.spesa_totale_comune), 2) +
        POWER((c1.spesa_branca_6 - c2.spesa_branca_6) / GREATEST(c1.spesa_totale_comune, c2.spesa_totale_comune), 2) +
        POWER((c1.spesa_branca_11 - c2.spesa_branca_11) / GREATEST(c1.spesa_totale_comune, c2.spesa_totale_comune), 2)
    ) as distanza_normalizzata,
    ABS(c1.eta_media_ponderata - c2.eta_media_ponderata) as differenza_eta
FROM comune_pivot c1
JOIN comune_pivot c2 ON c1.`comune assistito` < c2.`comune assistito`
WHERE c1.spesa_totale_comune > 500 AND c2.spesa_totale_comune > 500
ORDER BY distanza_normalizzata
LIMIT 20;
