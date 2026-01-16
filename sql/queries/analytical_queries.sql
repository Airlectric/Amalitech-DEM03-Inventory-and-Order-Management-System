-- 1. Rank products inside each category by revenue
SELECT 
    category,
    product_name,
    total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rank_in_category
FROM (
    SELECT 
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
    FROM Product p
    JOIN OrderItem oi ON p.product_id = oi.product_id
    JOIN `Order` o ON oi.order_id = o.order_id
    WHERE o.order_status IN ('Shipped', 'Delivered')
    GROUP BY p.product_id, p.category, p.product_name
) ranked
ORDER BY category, rank_in_category;

-- 2. Customer order frequency – show previous order date
WITH ordered_customers AS (
    SELECT 
        c.customer_id,
        c.full_name,
        o.order_id,
        o.order_date,
        LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date
    FROM Customer c
    JOIN `Order` o ON c.customer_id = o.customer_id
)
SELECT 
    full_name,
    order_date AS current_order_date,
    previous_order_date,
    TIMESTAMPDIFF(DAY, previous_order_date, order_date) AS days_between_orders
FROM ordered_customers
WHERE previous_order_date IS NOT NULL
ORDER BY days_between_orders;