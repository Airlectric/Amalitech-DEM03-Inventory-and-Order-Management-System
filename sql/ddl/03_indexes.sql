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
