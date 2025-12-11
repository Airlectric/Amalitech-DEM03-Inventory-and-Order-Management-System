/*
-----------------------------------------------
Creation of tables
--------------------------------------------
*/
-- Creation of Customer table
CREATE TABLE Customer(
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    shipping_address VARCHAR(255)
);


-- Creation of Product table
CREATE TABLE Product(
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0)
);

-- Creation of inventory table
CREATE TABLE Inventory (
    product_id INT NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0,

    PRIMARY KEY (product_id)
);


-- Creation of Order table
CREATE TABLE `Order`(
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    order_status VARCHAR(20) NOT NULL
);

-- Creation of OrderItem table
CREATE TABLE OrderItem (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL CHECK (price_at_purchase >= 0)
);




/*
----------------------------------
Addition of constraints to tables
-------------------------------------
*/
-- Foreign keys
ALTER TABLE `Order`
    ADD CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE;

ALTER TABLE OrderItem
    ADD CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id)
        REFERENCES `Order`(order_id)
        ON DELETE CASCADE;

ALTER TABLE OrderItem
    ADD CONSTRAINT fk_orderitem_products
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE;

ALTER TABLE Inventory
    ADD CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE;

-- Data Integrity constraint
ALTER TABLE Inventory
    ADD CONSTRAINT chk_inventory_quantity_non_negative
        CHECK(quantity_on_hand >= 0);


-- email constraint on customer
ALTER TABLE Customer
    ADD CONSTRAINT unique_email
        UNIQUE (email);



/*
-----------------------------------------------
Creation of indexes
--------------------------------------------
*/
-- Creation of indexes

-- for faster email lookup
CREATE INDEX idx_customer_email
ON Customer(email);

CREATE INDEX idx_order_date
ON `Order`(order_date);

CREATE INDEX idx_orderitem_product
ON OrderItem(product_id);

CREATE INDEX idx_inventory_quantity
ON Inventory(quantity_on_hand);

-- composite index on OrderItem for join performance
CREATE INDEX idx_orderitem_order_product
ON OrderItem(order_id, product_id);




/*
-----------------------------------------------
Creation of trigger functions or procedures
--------------------------------------------
*/

DELIMITER $$

-- This procedure calculates the total amount for a given order by summing all its OrderItems.
-- It also updates the order_status depending on whether the total is > 0.
CREATE PROCEDURE update_order_total(IN orderId INT)
BEGIN
    UPDATE `Order` o
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


-- This procedure sets the price_at_purchase in OrderItem to the current product price
CREATE PROCEDURE set_orderitem_price(IN orderItemId INT)
BEGIN
    UPDATE OrderItem oi
    JOIN Product p ON oi.product_id = p.product_id
    SET oi.price_at_purchase = p.price
    WHERE oi.order_item_id = orderItemId;
END$$

DELIMITER ;




/*
-----------------------------------------------
Creation of triggers
--------------------------------------------
*/

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