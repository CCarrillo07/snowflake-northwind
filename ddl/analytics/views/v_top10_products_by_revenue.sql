-- Top 10 Products by Revenue (using CTE and RANK)
CREATE OR REPLACE VIEW analytics.v_top10_products_by_revenue AS
WITH ranked_products AS (
  SELECT 
    product_id,
    product_name,
    SUM(line_total) AS total_revenue,
    RANK() OVER (ORDER BY SUM(line_total) DESC) AS revenue_rank
  FROM analytics.fact_order_lines
  GROUP BY product_id, product_name
)
SELECT product_id, product_name, total_revenue
FROM ranked_products
WHERE revenue_rank <= 10
ORDER BY revenue_rank;
