-- Customer-level churn risk scoring with percentile ranking
WITH customer_risk AS (
    SELECT
        customer_id,
        geography,
        gender,
        age,
        credit_score,
        balance,
        num_of_products,
        is_active_member,
        tenure,
        estimated_salary,
        exited,
        -- Rule-based churn risk score
        CASE WHEN age > 50              THEN 2
             WHEN age > 40              THEN 1
             ELSE 0 END +
        CASE WHEN balance = 0           THEN 1
             ELSE 0 END +
        CASE WHEN num_of_products >= 3  THEN 2
             WHEN num_of_products = 1   THEN 1
             ELSE 0 END +
        CASE WHEN is_active_member = 0  THEN 2
             ELSE 0 END +
        CASE WHEN credit_score < 580    THEN 2
             WHEN credit_score < 670    THEN 1
             ELSE 0 END +
        CASE WHEN tenure <= 1           THEN 2
             WHEN tenure <= 3           THEN 1
             ELSE 0 END                             AS risk_score
    FROM customers
),
ranked AS (
    SELECT *,
        CASE
            WHEN risk_score >= 7  THEN 'Very High Risk'
            WHEN risk_score >= 5  THEN 'High Risk'
            WHEN risk_score >= 3  THEN 'Medium Risk'
            ELSE 'Low Risk'
        END                                         AS risk_tier,
        RANK() OVER (
            ORDER BY risk_score DESC)               AS risk_rank,
        NTILE(10) OVER (
            ORDER BY risk_score DESC)               AS risk_decile,
        ROUND(AVG(risk_score) OVER (
            PARTITION BY geography)::NUMERIC, 2)    AS avg_risk_by_geography,
        ROUND(COUNT(customer_id) OVER (
            PARTITION BY geography)::NUMERIC, 0)    AS customers_in_geography
    FROM customer_risk
)
SELECT
    risk_tier,
    COUNT(customer_id)                              AS total_customers,
    SUM(exited)                                     AS actual_churned,
    ROUND(SUM(exited) * 100.0 /
        NULLIF(COUNT(customer_id), 0)::NUMERIC, 2)  AS churn_rate_pct,
    ROUND(AVG(risk_score)::NUMERIC, 2)              AS avg_risk_score,
    ROUND(AVG(balance)::NUMERIC, 2)                 AS avg_balance,
    ROUND(AVG(credit_score)::NUMERIC, 2)            AS avg_credit_score,
    ROUND(AVG(age)::NUMERIC, 2)                     AS avg_age
FROM ranked
GROUP BY risk_tier
ORDER BY avg_risk_score DESC;