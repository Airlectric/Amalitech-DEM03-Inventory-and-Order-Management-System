DELIMITER $$

/*
-----------------------------------------
TRIGGER FUNCTIONS (ACTUALLY Stored Procedures)
--------------------------------------------
*/

-- This procedure calculates the total amount for a given order by summing all its OrderItems.
-- It also updates the order_status depending on whether the total is > 0.
CREATE PROCEDURE update_order_total(IN orderId INT)
BEGIN
    UPDATE `Order` AS o
    SET
        o.total_amount = (
            SELECT COALESCE(SUM(quantity * price_at_purchase), 0)
            FROM OrderItem
            WHERE order_id = orderId
        ),

        -- Set order_status
        o.order_status = IF(o.total_amount > 0, 'Processing', 'Pending')
    
    WHERE o.order_id = orderId;
END$$


-- This procedure adds back stock to Inventory (used when an order item is deleted)
CREATE PROCEDURE restore_inventory(IN productId INT, IN qty INT)
BEGIN
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand + qty
    WHERE product_id = productId;
END$$


-- This procedure adjusts stock when the quantity of an OrderItem is updated
CREATE PROCEDURE adjust_inventory(IN productId INT, IN oldQty INT, IN newQty INT)
BEGIN
    -- Only update if quantity changed
    IF oldQty != newQty THEN
        UPDATE Inventory
        SET quantity_on_hand = quantity_on_hand + (oldQty - newQty)
        WHERE product_id = productId;
    END IF;
END$$


DELIMITER ;