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
    price DECIMAL(10,2) NOT NULL CHECK(price > 0)
);

--Creation of Order table
CREATE TABLE Order(
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0)
    order_status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE 
)

--Creation of OrderItem table
CREATE TABLE OrderItem (
    order_item_id INT NOT NULL AUTO_INCREMENT,
    order_id NOT NULL,
    product_id NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL CHECK (price_at_purchase > 0)
    CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id)
        REFERENCES `Order`(order_id)
        ON DELETE CASCADE
    CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
)