-- Churn rate by key demographic segments
WITH churn_demo AS (
    SELECT
        geography,
        gender,
        age_group,
        COUNT(customer_id)                          AS total_customers,
        SUM(exited)                                 AS churned_customers,
        ROUND(AVG(credit_score)::NUMERIC, 2)        AS avg_credit_score,
        ROUND(AVG(balance)::NUMERIC, 2)             AS avg_balance,
        ROUND(AVG(estimated_salary)::NUMERIC, 2)    AS avg_salary,
        ROUND(AVG(tenure)::NUMERIC, 2)              AS avg_tenure,
        ROUND(AVG(num_of_products)::NUMERIC, 2)     AS avg_products
    FROM customers
    WHERE age_group IS NOT NULL
    GROUP BY 
		geography, 
		gender, 
		age_group
)
SELECT *,
    ROUND(churned_customers * 100.0 /
        NULLIF(total_customers, 0)::NUMERIC, 2)     AS churn_rate_pct,
    RANK() OVER (
        ORDER BY churned_customers * 100.0 /
        NULLIF(total_customers, 0) DESC)            AS churn_rank
FROM churn_demo
ORDER BY churn_rate_pct DESC;