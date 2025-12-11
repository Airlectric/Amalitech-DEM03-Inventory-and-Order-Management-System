-- Customer Sales Summary View
CREATE OR REPLACE VIEW CustomerSalesSummary AS
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COALESCE(ROUND(SUM(o.total_amount), 2), 0) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM Customer c
LEFT JOIN `Order` o ON c.customer_id = o.customer_id AND o.order_status IN ('Shipped', 'Delivered')
GROUP BY c.customer_id, c.full_name, c.email;


-- SELECT * FROM CustomerSalesSummary ORDER BY total_spent DESC LIMIT 10;