-- Customer value segmentation by balance and activity
WITH segments AS (
    SELECT
        balance_segment,
        is_active_member,
        geography,
        COUNT(customer_id)                          AS total_customers,
        SUM(exited)                                 AS churned,
        ROUND(AVG(credit_score)::NUMERIC, 2)        AS avg_credit_score,
        ROUND(AVG(balance)::NUMERIC, 2)             AS avg_balance,
        ROUND(AVG(num_of_products)::NUMERIC, 2)     AS avg_products,
        ROUND(AVG(tenure)::NUMERIC, 2)              AS avg_tenure,
        ROUND(AVG(estimated_salary)::NUMERIC, 2)    AS avg_salary
    FROM customers
    WHERE balance_segment IS NOT NULL
    GROUP BY 
		balance_segment,
        is_active_member,
        geography
)
SELECT *,
    ROUND(churned * 100.0 /
        NULLIF(total_customers, 0)::NUMERIC, 2)     AS churn_rate_pct,
    RANK() OVER (
        ORDER BY avg_balance DESC)                  AS value_rank,
    ROUND(total_customers * 100.0 /
        SUM(total_customers) OVER ()::NUMERIC, 2)   AS pct_of_customers
FROM segments
ORDER BY avg_balance DESC;