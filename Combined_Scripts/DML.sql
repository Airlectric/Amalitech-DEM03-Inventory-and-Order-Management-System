/*
-----------------------------------------------
Queries
--------------------------------------------
*/

-- Business KPIs

-- 1. Total Revenue from completed orders
SELECT SUM(total_amount) AS total_revenue
FROM `Order`
WHERE order_status IN ('Shipped', 'Delivered');

-- 2. Top 10 Customers by total spending
SELECT 
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Top 5 Best-Selling Products by quantity
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM Product p
JOIN OrderItem oi ON p.product_id = oi.product_id
JOIN `Order` o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 4. Monthly Sales Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(total_amount) AS monthly_revenue
FROM `Order`
WHERE order_status IN ('Shipped', 'Delivered')
GROUP BY sales_month
ORDER BY sales_month;


-- Analytical Queries

-- 1. Rank products inside each category by revenue
SELECT 
    category,
    product_name,
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rank_in_category
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


/*
-----------------------------------------------
Views
--------------------------------------------
*/
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



/*
-----------------------------------------------
Stores Procedures
--------------------------------------------
*/

-- Stored Procedure: ProcessNewOrder
DELIMITER $$

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_product_id  INT,
    IN p_quantity    INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_current_stock INT;
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(12,2);

    -- Start transaction
    START TRANSACTION;

    -- Get current price and stock
    SELECT price, quantity_on_hand INTO v_price, v_current_stock
    FROM Product p
    JOIN Inventory i ON p.product_id = i.product_id
    WHERE p.product_id = p_product_id
    FOR UPDATE;  -- lock the rows

    -- Check stock
    IF v_current_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for product_id ${p_product_id}';
    END IF;

    -- Reduce inventory
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand - p_quantity
    WHERE product_id = p_product_id;

    -- Create the order (initially Pending, total will be updated by trigger)
    INSERT INTO `Order` (customer_id, total_amount, order_status)
    VALUES (p_customer_id, 0, 'Pending');

    SET v_order_id = LAST_INSERT_ID();

    -- Insert order item
    INSERT INTO OrderItem (order_id, product_id, quantity, price_at_purchase)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    -- Total will be automatically updated by the triggers

    COMMIT;

    SELECT v_order_id AS new_order_id;
END$$

DELIMITER ;