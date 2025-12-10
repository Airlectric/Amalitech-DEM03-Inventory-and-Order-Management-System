-- Insert Customers
INSERT INTO Customer(full_name, email, phone, shipping_address)
VALUES
('Daniel Doe', 'daniel@example.com', '0200000001', 'Accra, Ghana'),
('Ama Kofi', 'ama.kofi@example.com', '0200000002', 'Kumasi, Ghana'),
('Kwame Mensah', 'kwame@example.com', '0200000003', 'Cape Coast, Ghana'),
('Sarah Owusu', 'sarah@example.com', '0200000004', 'Tamale, Ghana'),
('Michael Tetteh', 'michael@example.com', '0200000005', 'Takoradi, Ghana');

-- Insert Products
INSERT INTO Product(product_name, category, price)
VALUES
('iPhone 15', 'Electronics', 1500.00),
('HP Laptop', 'Computers', 900.00),
('Samsung TV', 'Electronics', 700.00),
('Wireless Mouse', 'Accessories', 25.00),
('Office Chair', 'Furniture', 120.00),
('Bluetooth Speaker', 'Electronics', 60.00),
('Desk Lamp', 'Home', 30.00),
('Gaming Keyboard', 'Accessories', 85.00),
('Wrist Watch', 'Fashion', 45.00),
('Backpack', 'Fashion', 35.00);

-- Insert Inventory
INSERT INTO Inventory(product_id, quantity_on_hand)
VALUES
(1, 10),
(2, 7),
(3, 12),
(4, 50),
(5, 20),
(6, 30),
(7, 40),
(8, 25),
(9, 15),
(10, 60);

-- Insert Orders
INSERT INTO `Order` (customer_id, order_date, total_amount, order_status)
VALUES
(1, '2025-01-01', 0, 'Pending'),
(2, '2025-01-02', 0, 'Pending'),
(3, '2025-01-05', 0, 'Pending'),
(4, '2025-01-07', 0, 'Pending'),
(5, '2025-01-10', 0, 'Pending');

-- Insert Order Items (INITIAL PURCHASES)
INSERT INTO OrderItem(order_id, product_id, quantity, price_at_purchase)
VALUES
(1, 1, 1, 1500.00),   -- Daniel buys iPhone
(1, 4, 2, 25.00),     -- Daniel buys 2 mice
(2, 2, 1, 900.00),    -- Ama buys laptop
(2, 10, 1, 35.00),    -- Ama buys backpack
(3, 3, 1, 700.00),    -- Kwame buys Samsung TV
(4, 6, 3, 60.00),     -- Sarah buys speakers
(5, 5, 1, 120.00),    -- Michael buys office chair
(5, 8, 1, 85.00);     -- Michael buys gaming keyboard