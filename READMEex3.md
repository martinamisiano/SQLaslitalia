This project implements a pure SQL similarity analysis to compare municipalities based on healthcare spending patterns.
The approach:
Builds feature vectors per municipality
Normalizes spending across service categories
Computes pairwise similarity using distance metrics
Output:
 A ranked list of most similar municipalities based on healthcare behavior.
Designed for:
Feature engineering in analytics pipelines
Territorial benchmarking
Input for clustering or recommendation systems

healthcare_data (raw)
        │
        ▼
comune_profilo (aggregation by service type)
        │
        ▼
comune_pivot (feature engineering layer)
        │
        ▼
pairwise_similarity (distance computation)

.
├── sql/
│   └── municipality_similarity.sql
├── docs/
│   └── similarity_methodology.md
├── data/
│   └── sample_schema.sql
└── README.md

Computes per municipality and service type:
prestazioni → service count
spesa_totale → total spending
eta_media_utenti → average user age

Transforms categorical data into numerical feature vectors:
SUM(CASE WHEN branca ricetta = X THEN spesa_totale ELSE 0 END)
Generated features:
spesa_branca_2
spesa_branca_6
spesa_branca_11
spesa_branca_26
spesa_totale_comune
eta_media_ponderata
Filtering: 
HAVING spesa_totale_comune > 100
-removes low-signal municipalities 


Each municipality is compared to all others:
JOIN comune_pivot c2 
ON c1.`comune assistito` < c2.`comune assistito`
Distance Metric
Normalized Euclidean distance:
sqrt( Σ (feature_diff / max_total_spend)^2 )
Implemented as:
SQRT(
    POWER((spesa_branca_2_diff / max_spesa), 2) +
    POWER((spesa_branca_6_diff / max_spesa), 2) +
    POWER((spesa_branca_11_diff / max_spesa), 2)
)
ensures comparability across municipalities with different scales 

## Output Schema
Column	| Type	| Description
comune_a	|  STRING	|  First municipality
comune_b	|  STRING	|  Second municipality
distanza_normalizzata	| FLOAT	| Similarity score (lower = more similar)
differenza_eta	| FLOAT	| Age difference

Requirements
SQL engine supporting:
CTEs
Mathematical functions (SQRT, POWER)
Conditional aggregation
Run
-- Execute similarity analysis
\i sql/municipality_similarity.sql
Integration
Typical use cases:
Clustering preprocessing
Territorial segmentation
Recommendation systems (similar regions)
BI dashboards (similarity networks)

## Performance Considerations
Pairwise comparison: O(n²)
Use with:
Filtered datasets
Pre-aggregated tables
Optimization strategies:
Limit municipalities via thresholds
Precompute features as materialized view
Use approximate nearest neighbors for large-scale systems

## Engineering Notes
Normalization uses:
GREATEST(c1.spesa_totale_comune, c2.spesa_totale_comune)
   Prevents bias toward smaller municipalities
Thresholding:
WHERE spesa_totale_comune > 500
    Ensures meaningful comparisons
Deterministic and reproducible
No external dependencies


Recommended checks:
No null feature vectors
Positive spending values
Balanced distribution across branches
Distance symmetry (A–B = B–A logically ensured)

Martina Misiano
