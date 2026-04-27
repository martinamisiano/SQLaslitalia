Project Description
This project implements a SQL-based forecasting model to support healthcare resource allocation.
It combines:
Seasonality patterns (monthly behavior)
Growth trends (linear trend estimation)
Volatility metrics (demand variability)
 Output:
Actionable forecasts for:
Service demand (volume)
Associated costs
Designed for:
Capacity planning
Budget forecasting
Operational optimization

healthcare_data (raw)
        │
        ▼
monthly_data (time aggregation)
        │
        ▼
seasonal_patterns (seasonality layer)
        │
        ▼
growth_trends (trend estimation)
        │
        ▼
forecast_output (prediction layer)

.
├── sql/
│   └── healthcare_resource_forecast.sql
├── docs/
│   └── forecasting_methodology.md
├── data/
│   └── sample_schema.sql
└── README.md

Core SQL Logic
1. Time Aggregation (monthly_data)
Aggregates raw data into monthly metrics:
monthly_volume → number of services
monthly_cost → total cost
Grouped by:
Discipline (disciplina erogatore)
Year / Month
2. Seasonality Layer (seasonal_patterns)
Captures recurring patterns per month:
volume_medio_stagionale
costo_medio_stagionale
volatilità_volume (standard deviation)
AVG(monthly_volume)
STDDEV(monthly_volume)
Identifies cyclic demand behavior
3. Trend Estimation (growth_trends)
Implements linear regression slope in SQL:
cov(time, volume) / var(time)
Using:
periodo_numerico → continuous time index
volume_mensile → dependent variable
 Produces:
crescita_mensile (growth rate)
4. Forecast Logic
Forecast is computed as:
forecast = seasonal_average * (1 + growth_rate)
Outputs:
forecast_volume
forecast_costo
 Combines:
Seasonality (baseline)
Trend (adjustment)
5. Confidence Signal (Volatility-Based)
Volatility is used as a proxy for uncertainty:
High volatility → lower confidence
Low volatility → stable forecast
(Extendable to full confidence intervals)

Output Schema
Column	Type	Description
disciplina erogatore	STRING	Medical discipline
mese	INT	Month
volume_medio_stagionale	FLOAT	Seasonal avg volume
costo_medio_stagionale	FLOAT	Seasonal avg cost
volatilità_volume	FLOAT	Demand variability
crescita_mensile	FLOAT	Trend coefficient
forecast_volume	FLOAT	Predicted demand
forecast_costo	FLOAT	Predicted cost

Performance Considerations
Aggregation: O(n)
Trend computation: O(k)
Scales well with:
Partitioning by time
Pre-aggregated monthly tables

Martina Misiano
