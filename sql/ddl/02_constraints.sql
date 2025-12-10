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