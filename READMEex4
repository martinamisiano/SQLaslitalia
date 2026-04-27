This project implements a SQL-based predictive analytics pipeline to estimate future healthcare spending using demographic and behavioral features.
The approach:
Builds cohort-based aggregations
Engineers features for predictive modeling
Computes correlations between age and spending
Produces a lightweight prediction signal directly in SQL

healthcare_data (raw)
        │
        ▼
monthly_cohorts (cohort aggregation)
        │
        ▼
regression_features (feature engineering)
        │
        ▼
correlation_analysis (statistical layer)
        │
        ▼
prediction_output (scoring layer)

.
├── sql/
│   └── healthcare_spending_prediction.sql
├── docs/
│   └── predictive_methodology.md
├── data/
│   └── sample_schema.sql
└── README.md

Cohort Aggregation (monthly_cohorts)
Builds demographic cohorts by:
Year / Month
Age class (classe età)
Gender (sesso)
Service type (branca ricetta)
Metrics:
popolazione_coorte → cohort size
spesa_media_per_persona → avg cost per user
volume_prestazioni → service volume
diversità_prestazioni → service diversity
Filtering:
HAVING popolazione_coorte >= 3
 Ensures statistical robustness

Feature Engineering (regression_features)
Derived features:
Interaction term:
classe età * volume_prestazioni
Normalized diversity:
diversità_prestazioni / popolazione_coorte
Binary encoding:
CASE WHEN sesso = 'M' THEN 1 ELSE 0 END
Ranking within cohort:
ROW_NUMBER() OVER (
    PARTITION BY classe età, sesso 
    ORDER BY spesa_media_per_persona DESC
)
 Identifies top spending cohorts

Implements Pearson correlation (manual SQL):
cov(X,Y) / (std(X) * std(Y))
Computed between:
Age (classe età)
Spending (spesa_media_per_persona)
Also derives:
Gender-based spending averages
Gender gap

Rule-based prediction:
CASE 
    WHEN correlazione_eta_spesa > 0.5 THEN 
        spesa * (1 + correlazione * 0.1)
    ELSE spesa
END
 Interpretation:
Strong age-spending correlation → upward adjustment
Weak correlation → stable projection


## Output Schema
Column	Type	Description
branca ricetta	STRING	Service category
classe età	INT	Age class
sesso	STRING	Gender
spesa_media_per_persona	FLOAT	Current avg spend
correlazione_eta_spesa	FLOAT	Age-spend correlation
gap_genere	FLOAT	Male vs female gap
spesa_predetta_prossimo_periodo	FLOAT	Predicted spending

Performance Considerations
Aggregation: O(n)
Feature engineering: O(n)
Correlation layer: O(k)
Scales well with:
Partitioning by time (Anno, mese)
Pre-aggregated cohort tables

Engineering Notes
Fully SQL-native predictive logic
No external ML dependencies
Deterministic and reproducible
Easily portable across warehouses
Filters ensure:
Valid gender values
Reasonable age range
Minimum cohort size

Extensions
Replace rule-based prediction with:
Linear regression (in SQL or Python)
Gradient boosting models
Add features:
Chronic conditions
Geographic variables
Seasonal effects
Introduce:
Time series forecasting (ARIMA, Prophet)
Lag features

Martina Misiano
