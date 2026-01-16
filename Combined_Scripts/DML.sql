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

-- Testing view
SELECT * FROM CustomerSalesSummary;


/*
-----------------------------------------------
Stores Procedures
--------------------------------------------
*/

-- Stored Procedure: ProcessNewOrder
DELIMITER $$
DROP PROCEDURE IF EXISTS ProcessNewOrder$$
CREATE PROCEDURE ProcessNewOrder(
    IN customerId INT,
    IN productId INT,
    IN quantityOrder INT
)
BEGIN
    DECLARE price DECIMAL(10,2);
    DECLARE currentStock INT;
    DECLARE newOrderId INT;
    DECLARE err_msg VARCHAR(255);

    -- Start transaction
    START TRANSACTION;

    -- Get current price and stock (lock rows to prevent race conditions)
    SELECT
        p.price,
        i.quantity_on_hand
    INTO
        price,
        currentStock
    FROM
        Product p
        JOIN Inventory i ON p.product_id = i.product_id
    WHERE
        p.product_id = productId
    FOR UPDATE;

    -- Check stock availability
    IF currentStock < quantityOrder THEN
        SET err_msg = CONCAT('Insufficient stock for product_id ', productId);
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_msg;
    END IF;

    -- Reduce inventory
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand - quantityOrder
    WHERE product_id = productId;

    -- Create order (total will be updated by trigger)
    INSERT INTO `Order` (
        customer_id,
        total_amount,
        order_status
    )
    VALUES (
        customerId,
        0,
        'Pending'
    );

    -- Get generated order ID
    SET newOrderId = LAST_INSERT_ID();

    -- Insert order item (trigger will handle price)
    INSERT INTO OrderItem (
        order_id,
        product_id,
        quantity
    )
    VALUES (
        newOrderId,
        productId,
        quantityOrder
    );

    -- Commit transaction
    COMMIT;

    -- Return the new order ID
    SELECT newOrderId AS new_order_id;
END$$
DELIMITER ;


-- For processing bulk orders from a user
DELIMITER $$
DROP PROCEDURE IF EXISTS ProcessBulkOrder$$
CREATE PROCEDURE ProcessBulkOrder(
    IN customerId INT,
    IN items JSON
)
BEGIN
    DECLARE newOrderId INT;
    DECLARE err_msg VARCHAR(255);

    -- Start transaction
    START TRANSACTION;

    -- Create order
    INSERT INTO `Order` (
        customer_id,
        total_amount,
        order_status
    )
    VALUES (
        customerId,
        0,
        'Pending'
    );

    SET newOrderId = LAST_INSERT_ID();

    -- Insert order items in bulk
    INSERT INTO OrderItem (order_id, product_id, quantity)
    SELECT
        newOrderId,
        jt.product_id,
        jt.quantity
    FROM
        JSON_TABLE(
            items,
            '$[*]'
            COLUMNS (
                product_id INT PATH '$.product_id',
                quantity INT PATH '$.quantity'
            )
        ) AS jt;

    -- Validate stock in one check
    IF EXISTS (
        SELECT 1
        FROM Inventory i
        JOIN (
            SELECT
                jt.product_id,
                SUM(jt.quantity) AS total_quantity
            FROM
                JSON_TABLE(
                    items,
                    '$[*]'
                    COLUMNS (
                        product_id INT PATH '$.product_id',
                        quantity INT PATH '$.quantity'
                    )
                ) jt
            GROUP BY jt.product_id
        ) req ON req.product_id = i.product_id
        WHERE i.quantity_on_hand < req.total_quantity
    ) THEN
        SET err_msg = 'Insufficient stock for one or more products';
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_msg;
    END IF;

    -- Reduce inventory in bulk
    UPDATE Inventory i
    JOIN (
        SELECT
            jt.product_id,
            SUM(jt.quantity) AS total_quantity
        FROM
            JSON_TABLE(
                items,
                '$[*]'
                COLUMNS (
                    product_id INT PATH '$.product_id',
                    quantity INT PATH '$.quantity'
                )
            ) jt
        GROUP BY jt.product_id
    ) req ON req.product_id = i.product_id
    SET i.quantity_on_hand = i.quantity_on_hand - req.total_quantity;

    -- Commit transaction
    COMMIT;

    -- Return the new order ID
    SELECT newOrderId AS new_order_id;
END$$
DELIMITER ;



/* ------------------------------------------------------

Test Cases for stored procedures
----------------------------------------------------------*/

-- Test single order
CALL ProcessNewOrder(1, 21, 2);



-- Test bulk order with JSON array
CALL ProcessBulkOrder(
    1,
    '[
        {"product_id": 23, "quantity": 2},
        {"product_id": 17, "quantity": 1},
        {"product_id": 3, "quantity": 5}
    ]'
);

