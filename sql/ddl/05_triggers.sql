DELIMITER $$

-- Fires automatically AFTER a new OrderItem row is inserted
-- Calls the update_order_total procedure to recalculate the order's total
CREATE TRIGGER orderitem_after_insert
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    CALL update_order_total(NEW.order_id)
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






DELIMITER ;