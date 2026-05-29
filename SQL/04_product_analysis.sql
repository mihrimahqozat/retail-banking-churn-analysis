-- Churn by product usage and engagement
WITH product_stats AS (
    SELECT
        num_of_products,
        is_active_member,
        has_cr_card,
        COUNT(customer_id)                          AS total_customers,
        SUM(exited)                                 AS churned,
        ROUND(AVG(credit_score)::NUMERIC, 2)        AS avg_credit_score,
        ROUND(AVG(balance)::NUMERIC, 2)             AS avg_balance,
        ROUND(AVG(tenure)::NUMERIC, 2)              AS avg_tenure,
        ROUND(AVG(estimated_salary)::NUMERIC, 2)    AS avg_salary
    FROM customers
    GROUP BY 
		num_of_products,
        is_active_member,
        has_cr_card
)
SELECT *,
    ROUND(churned * 100.0 /
        NULLIF(total_customers, 0)::NUMERIC, 2)     AS churn_rate_pct,
    RANK() OVER (
        ORDER BY churned * 100.0 /
        NULLIF(total_customers, 0) DESC)            AS churn_rank
FROM product_stats
ORDER BY churn_rate_pct DESC;