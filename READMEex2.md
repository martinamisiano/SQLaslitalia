## Project Description
This project implements a pure SQL anomaly detection pipeline to identify abnormal cost patterns in healthcare services.
The analysis operates at the level of:
Medical discipline (disciplina erogatore)
Specific service (prestazione)
It detects:
Extreme high-cost outliers
Suspicious low-cost entries
Statistical anomalies using z-score
No machine learning is required — the approach is:
Fully deterministic
Explainable
Easily deployable in modern data warehouses


healthcare_data (raw)
        │
        ▼
disciplina_baseline (statistical baseline)
        │
        ▼
anomalie (row-level anomaly scoring)
        │
        ▼
aggregated_anomalies (reporting layer)

.
├── sql/
│   └── cost_anomaly_detection.sql
├── docs/
│   └── anomaly_methodology.md
├── data/
│   └── sample_schema.sql
└── README.md


Core SQL Logic
1. Baseline Layer (disciplina_baseline)
Builds statistical benchmarks per:
discipline
service
Metrics computed:
frequenza → sample size
costo_medio → average cost
deviazione_std → standard deviation
mediana → robust central tendency
p95 → high percentile threshold
HAVING frequenza >= 3
Ensures statistical reliability (filters low-sample noise)

Each record is enriched with baseline metrics and scored.
Z-score formula:
ABS(importo - costo_medio) / deviazione_std
Classification Logic:
CASE 
    WHEN importo > p95 * 2 THEN 'OUTLIER_ALTO'
    WHEN importo < costo_medio * 0.1 THEN 'OUTLIER_BASSO'
    WHEN z_score > 3 THEN 'ANOMALIA_STATISTICA'
    ELSE 'NORMALE'
END
Types of anomalies:
Type	|   Description
OUTLIER_ALTO	|   Extreme high cost
OUTLIER_BASSO	| Suspiciously low cost
ANOMALIA_STATISTICA	| High deviation from mean
NORMALE	|  Within expected range

Filters and aggregates anomalies:
WHERE tipo_anomalia != 'NORMALE'
Outputs grouped insights:
Total anomalies
Average severity (z_score_medio)
Maximum anomalous value
Involved providers (STRING_AGG)

## output schema
Column	Type	Description
disciplina erogatore	STRING	Medical discipline
prestazione	STRING	Service
anomalie_totali	INT	Number of anomalies
z_score_medio	FLOAT	Average anomaly severity
importo_max_anomalo	FLOAT	Max anomalous cost
tipo_anomalia	STRING	Anomaly classification
aziende_coinvolte	STRING	Providers involved


## Performance Considerations
Baseline aggregation: O(n)
Join + scoring: O(n)
Final aggregation: O(k)
Efficient for large datasets if:
Indexed on:
disciplina erogatore
prestazione
Partitioned by time (optional)

Handles division by zero safely:
NULLIF(deviazione_std, 0)
Filters invalid data:
Null disciplines
Non-positive costs
Works well in:
dbt models
ELT pipelines
Incremental builds

## Extensions
Add:
Time-based anomaly detection (trend shifts)
Provider-level scoring
Patient-level normalization
Replace z-score with:
Robust z-score (median-based)
IQR-based detection
Integrate with:
Alerting systems (e.g. Airflow, dbt exposures)

Martina Misiano
