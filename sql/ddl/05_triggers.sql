DELIMITER $$

-- Fires automatically AFTER a new OrderItem row is inserted
-- Calls the update_order_total procedure to recalculate the order's total
CREATE TRIGGER orderitem_after_insert
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    CALL update_order_total(NEW.order_id);
END$$


-- Fires automatically AFTER an existing OrderItem row is updated
-- Updates both the order total and adjusts inventory if quantity changed
CREATE TRIGGER orderitem_after_update
AFTER UPDATE ON OrderItem
FOR EACH ROW
BEGIN
    CALL update_order_total(NEW.order_id);
    CALL adjust_inventory(NEW.product_id, OLD.quantity, NEW.quantity);
END$$

-- Fires automatically AFTER an OrderItem is deleted
-- Updates the order total and restores inventory for the deleted item
CREATE TRIGGER orderitem_after_delete
AFTER DELETE ON OrderItem
FOR EACH ROW
BEGIN
    CALL update_order_total(OLD.order_id);
    CALL restore_inventory(OLD.product_id, OLD.quantity);
END$$

-- Fires automatically BEFORE inserting a new OrderItem
-- Sets the price_at_purchase to the current Product price
CREATE TRIGGER orderitem_before_insert
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    -- Set price_at_purchase from Product.price
    SET NEW.price_at_purchase = (SELECT price FROM Product WHERE product_id = NEW.product_id);
END$$




DELIMITER ;