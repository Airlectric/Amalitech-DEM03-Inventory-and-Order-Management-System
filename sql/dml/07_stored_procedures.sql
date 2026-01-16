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