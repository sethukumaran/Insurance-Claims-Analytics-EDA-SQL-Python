# Insurance Claims Analytics — EDA, SQL & Python

## Executive summary

This project performs a senior-analyst style review of an auto-insurance claims portfolio using **Python EDA, SQL analysis, relational joins, data-quality validation, business segmentation, and visualization**.

### Portfolio headline KPIs

| KPI | Result |
|---|---:|
| Claims | 50,000 |
| Reported claim amount | $369,144,984.58 |
| Paid amount | $229,698,733.61 |
| Open reserve | $41,963,412.56 |
| Average claim | $7,382.90 |
| Paid-claim settlement ratio | 80.1% |
| Overall paid-to-claim ratio | 62.2% |
| Denial rate | 10.8% |
| Avg. reporting lag | 5.0 days |
| Avg. settlement lag | 25.1 days |

## Data model

- `claims.csv` — claim/loss transactions
- `claim_payments.csv` — claim payment transactions
- `policies.csv` — coverage, premium, deductible and policy relationships
- `policyholders.csv` — customer and credit-band attributes
- `vehicles.csv` — vehicle attributes

The analysis joins claims → policies → policyholders/vehicles and reconciles claims to payment transactions.

## EDA process

The initial Python EDA covers:

1. Shape and schema
2. Data types
3. Missing values
4. Duplicates
5. Cardinality and primary-key checks
6. Numeric distributions
7. Categorical distributions
8. Date-range checks
9. Relational integrity
10. Payment reconciliation
11. Reporting and settlement lags
12. Outlier/anomaly screening

### Data-quality result

The core joins are complete and payment totals reconcile. No claim was reported before its loss date and no claim fell outside its policy period.

One notable issue was found: **6,177 claims have a vehicle model year later than the loss date**. This should be investigated before vehicle-age-based predictive modeling.

## Business insights

### 1. Collision is the main cost driver

Collision is the dominant peril with approximately **$213,468,071** of reported claim amount. It is the clearest starting point for loss-prevention, automation, repair-network, and severity-management initiatives.

### 2. Geographic concentration

The highest claim-volume states are **TX, CA, FL**. State × peril analysis shows collision losses in major states as the largest exposure clusters.

### 3. Reserve backlog

Open claims carry approximately **$41,963,413** of reserve. The investigation population is especially important because it contains older unresolved cases and therefore deserves aging-based escalation and operational review.

### 4. Repeat-claim behavior

There are **1,026 policyholders with more than five claims**, and the highest-frequency policyholder has **45 claims**. This is a risk-screening signal—not proof of fraud—and should feed a broader fraud/abuse workflow.

### 5. Coverage economics

The paid-to-premium calculations in `coverage_economics_proxy.csv` are **directional only**. A formal actuarial loss ratio requires earned premium/exposure aligned to claim periods.

### 6. Recent claims are immature

Recent loss-month paid-to-claim ratios are not directly comparable with older periods because newer claims have had less time to mature. Payment-month cash flow and claim-development views are more appropriate for recent performance monitoring.

## SQL analysis

`sql/insurance_claims_analysis.sql` contains queries for:

- Executive KPIs
- Peril performance
- State concentration
- Coverage economics
- Reserve backlog
- State × peril concentration
- Payment methods and payees
- Repeat-claim policyholders
- Data-integrity checks

## Python analysis

`python/insurance_claims_eda.py` demonstrates:

- Initial EDA
- Data-quality checks
- Relational joins
- KPI calculations
- Segmentation
- Visualization

## Visualizations

- `01_claim_status.png` — claim status mix
- `02_claim_amount_by_peril.png` — claim dollars by peril
- `03_claim_volume_by_state.png` — claim volume by state
- `04_monthly_claim_volume.png` — monthly claim trend
- `05_monthly_cash_paid.png` — payment cash-flow trend
- `06_open_reserve_by_status.png` — open reserve exposure
- `07_claim_severity_distribution.png` — severity distribution

## Conclusion

The portfolio is characterized by a **large collision-driven loss burden, meaningful geographic concentration, and a material open-reserve requirement**. The strongest business opportunities are to reduce collision losses, improve investigation backlog management, strengthen repeat-claim risk screening, and use state × peril segmentation to focus underwriting and claims resources.

The supplied data is structurally consistent across the main joins and payment reconciliation. The principal data-quality concern is the set of future-model-year vehicle observations. The next analytical maturity step is to add earned-exposure loss ratios, claim development analysis, fraud propensity modeling, severity/frequency models, and reserve adequacy analysis.

