# SQLaslitalia
This project implements a pure SQL clustering strategy to analyze and compare healthcare performance across Italian Local Health Authorities (ASL).
The pipeline:
Aggregates raw healthcare data
Computes normalized performance indicators
Applies pairwise similarity logic
Outputs interpretable clusters without ML dependencies
Designed for:
Analytics engineering workflows
Data warehouse environments (BigQuery, Snowflake, PostgreSQL)
BI integration

healthcare_data (raw)
        │
        ▼
asl_metrics (aggregation layer)
        │
        ▼
asl_percentili (normalization layer)
        │
        ▼
pairwise_comparison (clustering logic)


.
├── sql/
│   └── asl_clustering.sql
├── docs/
│   └── methodology.md
├── data/
│   └── sample_schema.sql
└── README.md

Aggregation Layer (asl_metrics)
Computes per-ASL KPIs:
prestazioni_totali → total services
costo_medio → average cost
spesa_totale → total expenditure
comuni_coperti → geographic coverage
specializzazioni → service diversity
eta_media_ponderata → weighted average age
Weighted average formula:
SUM(classe età * numero prestazione) / SUM(numero prestazione)

Uses window functions:
PERCENT_RANK() OVER (ORDER BY spesa_totale)
PERCENT_RANK() OVER (ORDER BY costo_medio)
Purpose:
Remove scale bias
Enable cross-ASL comparability

Each ASL is compared against all others:
JOIN asl_percentili a2 
ON a1.`ASL assistito` < a2.`ASL assistito`
Similarity rule:
ABS(percentile_spesa_diff) < 0.1
AND ABS(percentile_costo_diff) < 0.1

Instead of using predefined clusters, this query:
Aggregates key performance metrics per ASL
Computes relative positioning (percentiles)
Compares ASLs pairwise
Flags statistically similar entities
This enables a transparent and explainable clustering approach, without black-box algorithms.

The query expects a table:
With the following fields:
Column	|   Description:
ASL assistito	| Local Health Authority
importo (euro)	| Cost of service
comune assistito	| Patient municipality
disciplina erogatore	| Medical specialization
classe età	| Age class (numeric)
numero prestazione	| Number of services

🔍 Metrics Computed
For each ASL:
Total services (prestazioni_totali)
Average cost per service (costo_medio)
Total healthcare spending (spesa_totale)
Geographical coverage (comuni_coperti)
Service diversity (specializzazioni)
Weighted average age (eta_media_ponderata)

## Methodology
1. Aggregation Layer
All metrics are computed per ASL.
2. Normalization via Percentiles
We calculate:
Spending percentile
Average cost percentile
This allows fair comparison across heterogeneous ASLs.
3. Pairwise Comparison
Each ASL is compared with all others based on:
Cost difference
Age difference
Percentile proximity
4. Clustering Logic
Two ASLs are classified as:
CLUSTER_SIMILE
→ if both spending and cost percentiles differ by less than 10%
DIVERSO
→ otherwise

## Output
The query returns:
Column	|   Description
asl_principale	|  First ASL
asl_confronto	| Compared ASL
differenza_costo	|  Absolute cost difference
differenza_eta	|  Difference in weighted age
tipo_relazione	|  Similar or different

This approach enables:
Benchmarking: Compare similar healthcare providers
Efficiency analysis: Detect cost anomalies
Policy insights: Support resource allocation decisions
Scalability: Works on large datasets with pure SQL

## Possible Extensions
Add quality indicators (e.g. outcomes, readmission rates)
Replace threshold (10%) with dynamic clustering techniques
Integrate machine learning models (k-means, hierarchical clustering)
Visualize clusters using network graphs

## Performance Considerations
Time complexity: O(n²) due to pairwise join
Recommended for:
≤ 500 ASLs (safe range)
Optimization strategies:
Pre-filter by region
Use clustering keys / partitioning
Replace cross join with approximate nearest neighbors (if scaling)

Martina Misiano
