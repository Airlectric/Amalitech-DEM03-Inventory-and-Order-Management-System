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