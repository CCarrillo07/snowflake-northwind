-- Top 10 Products by Revenue (using CTE and RANK)
CREATE OR REPLACE VIEW analytics.v_top10_products_by_revenue AS
WITH ranked_products AS (
  SELECT 
    f.product_id,
    SUM(f.line_total) AS total_revenue,
    RANK() OVER (ORDER BY SUM(f.line_total) DESC) AS revenue_rank
  FROM analytics.fact_order_lines f
  GROUP BY f.product_id
)
SELECT 
    r.product_id, 
    p.product_name, 
    r.total_revenue
FROM ranked_products r
JOIN analytics.dim_products p ON r.product_id = p.product_id
WHERE r.revenue_rank <= 10
ORDER BY r.revenue_rank;
