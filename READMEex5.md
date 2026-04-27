Project Description
This project implements a SQL-based KPI and efficiency framework for healthcare providers.
It delivers:
Operational metrics (volume, diversity)
Financial KPIs (cost, revenue)
Efficiency indicators (cost per patient, utilization)
Benchmark comparisons
A composite efficiency score
 Designed for stakeholder dashboards, performance monitoring, and decision support.

 healthcare_data (raw)
        │
        ▼
performance_metrics (KPI layer)
        │
        ▼
benchmarks (reference layer)
        │
        ▼
scoring_output (classification + scoring)

.
├── sql/
│   └── healthcare_kpi_dashboard.sql
├── docs/
│   └── kpi_methodology.md
├── data/
│   └── sample_schema.sql
└── README.md

Core SQL Logic
1. KPI Layer (performance_metrics)
Aggregates metrics per:
Provider (azienda erogante)
Discipline (disciplina erogatore)
Service category (branca ricetta)
Volume Metrics
pazienti_unici
prestazioni_totali
tipologie_prestazioni
Financial Metrics
ricavi_totali
ricavo_medio_prestazione
Efficiency Metrics
costo_per_paziente = ricavi_totali / pazienti_unici
prestazioni_per_paziente = prestazioni_totali / pazienti_unici
Demographic Metrics
eta_media_pazienti
percentuale_femmine
Filtering:
HAVING pazienti_unici >= 5
 Ensures statistical reliability
2. Benchmark Layer (benchmarks)
Computes discipline-level reference values:
Median cost per patient
75th percentile of services per patient
Average revenue per service
PERCENTILE_CONT(0.5)
PERCENTILE_CONT(0.75)
 Provides relative performance context
3. Classification Logic
CASE 
    WHEN costo_per_paziente > mediana * 1.5 THEN 'ALTO_COSTO'
    WHEN prestazioni_per_paziente > q3 * 1.2 THEN 'ALTO_VOLUME'
    WHEN ricavo_medio_prestazione > benchmark * 1.3 THEN 'ALTO_VALORE'
    ELSE 'STANDARD'
END
Performance categories:
Category	Meaning
ALTO_COSTO	Potential inefficiency
ALTO_VOLUME	High utilization
ALTO_VALORE	High-value services
STANDARD	Within benchmark
4. Efficiency Score
Composite KPI:
( cost_efficiency * 0.4 ) +
( volume_efficiency * 0.3 ) +
( value_efficiency * 0.3 )
Implemented as:
(1 / (1 + costo_ratio)) * 0.4 +
(volume_ratio) * 0.3 +
(value_ratio) * 0.3
 Balanced scoring:
Penalizes high costs
Rewards productivity and value


Output Schema
Column	Type	Description
azienda erogante	STRING	Provider
disciplina erogatore	STRING	Discipline
branca ricetta	INT	Service category
pazienti_unici	INT	Unique patients
prestazioni_totali	INT	Total services
ricavi_totali	FLOAT	Total revenue
costo_per_paziente	FLOAT	Cost efficiency
prestazioni_per_paziente	FLOAT	Utilization
categoria_performance	STRING	Classification
efficiency_score	FLOAT	Composite KPI


Performance Considerations
Aggregation complexity: O(n)
Benchmark computation: O(k)
Efficient for large datasets if:
Indexed by:
azienda erogante
disciplina erogatore
Materialized as:
KPI table
BI-ready dataset

Testing Strategy
Recommended checks:
No division by zero
KPI ranges are valid (no negative values)
Percentiles correctly computed
Efficiency score bounded (sanity checks)

Extensions
Add:
Time-based trends (monthly KPIs)
Risk adjustment (case mix index)
Outcome-based metrics
Improve scoring:
Weighted dynamically
ML-based scoring
Integrate with:
BI tools (Power BI, Tableau)
Alerting systems
