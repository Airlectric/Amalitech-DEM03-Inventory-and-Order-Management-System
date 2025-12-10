-- 1. Total Revenue from completed orders
SELECT ROUND(SUM(total_amount), 2) AS total_revenue
FROM `Order`
WHERE order_status IN ('Shipped', 'Delivered');

-- 2. Top 10 Customers by total spending
SELECT 
    c.full_name,
    ROUND(SUM(o.total_amount), 2) AS total_spent
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Top 5 Best-Selling Products by quantity
SELECT 
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM Product p
JOIN OrderItem oi ON p.product_id = oi.product_id
JOIN `Order` o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 4. Monthly Sales Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(total_amount), 2) AS monthly_revenue
FROM `Order`
WHERE order_status IN ('Shipped', 'Delivered')
GROUP BY sales_month
ORDER BY sales_month;