-- Sample Data Insertion Script for E-commerce Database

-- 1. 25 Customers
INSERT INTO Customer (full_name, email, phone, shipping_address)
VALUES
    ('Daniel Kofi Doe',         'daniel.doe@example.com',       '0201234561', 'Accra, Greater Accra'),
    ('Ama Serwaa Mensah',       'ama.serwaa@example.com',       '0249876543', 'Kumasi, Ashanti Region'),
    ('Kwame Osei Tutu',         'kwame.osei@example.com',       '0551112233', 'Cape Coast, Central Region'),
    ('Sarah Abena Owusu',       'sarah.owusu@example.com',      '0504445566', 'Tamale, Northern Region'),
    ('Michael Tetteh Quarshie', 'michael.tetteh@example.com',   '0278899001', 'Takoradi, Western Region'),
    ('Fatima Abdulai',          'fatima@example.com',           '0532233445', 'Bolgatanga, Upper East'),
    ('Joseph Nii Armah',        'joseph.armah@example.com',     '0205566778', 'Ho, Volta Region'),
    ('Grace Adjei',             'grace.adjei@example.com',      '0547788990', 'Sunyani, Bono Region'),
    ('Ebenezer Sackey',         'ebenezer@example.com',         '0261122334', 'Koforidua, Eastern Region'),
    ('Patience Boateng',        'patience.b@example.com',       '0556677889', 'Wa, Upper West'),
    ('Isaac Newton Amponsah',   'isaac.amponsah@example.com',   '0245566778', 'Accra, Greater Accra'),
    ('Jennifer Agyemang',       'jennifer.a@example.com',       '0509988776', 'Kumasi, Ashanti Region'),
    ('Samuel Kwesi Annan',      'samuel.annan@example.com',     '0273344556', 'Tema, Greater Accra'),
    ('Linda Asantewaa',         'linda.asante@example.com',     '0536677889', 'Obuasi, Ashanti Region'),
    ('Richard Opoku',           'richard.opoku@example.com',    '0204455667', 'Sekondi, Western Region'),
    ('Victoria Naa Odey',       'victoria.odey@example.com',    '0541122334', 'Accra, Greater Accra'),
    ('Emmanuel Darko',          'emmanuel.darko@example.com',   '0267788990', 'Tamale, Northern Region'),
    ('Priscilla Yeboah',        'priscilla.y@example.com',      '0558899001', 'Cape Coast, Central Region'),
    ('Bernard Fiifi Yankson',   'bernard.yankson@example.com',  '0243344556', 'Takoradi, Western Region'),
    ('Mercy Oforiwaa',          'mercy.ofori@example.com',      '0506677889', 'Kumasi, Ashanti Region'),
    ('David Nsiah',             'david.nsiah@example.com',      '0278899002', 'Sunyani, Bono Region'),
    ('Abigail Amoah',           'abigail.amoah@example.com',    '0534455667', 'Ho, Volta Region'),
    ('Frank Kwadwo Asare',      'frank.asare@example.com',      '0209988776', 'Accra, Greater Accra'),
    ('Theresa Baidoo',          'theresa.baidoo@example.com',   '0551122334', 'Koforidua, Eastern Region'),
    ('Joshua Mensah Baah',      'joshua.mbaah@example.com',     '0265566779', 'Tamale, Northern Region');

-- 2. 30 Products (8 categories)
INSERT INTO Product (product_name, category, price)
VALUES
    ('iPhone 15 Pro Max',      'Electronics', 1850.00),
    ('Samsung Galaxy S24 Ultra','Electronics', 1650.00),
    ('MacBook Pro 16" M3',     'Computers',   3200.00),
    ('Dell XPS 15',            'Computers',   2100.00),
    ('Sony 65" 4K TV',         'Electronics', 1400.00),
    ('LG OLED 55"',            'Electronics', 1100.00),
    ('Logitech MX Master 3S',  'Accessories',  95.00),
    ('Razer BlackWidow V4',    'Accessories', 180.00),
    ('Herman Miller Chair',    'Furniture',   1200.00),
    ('IKEA Office Desk',       'Furniture',    250.00),
    ('JBL Flip 6 Speaker',     'Electronics',   89.00),
    ('Anker Power Bank 20K',   'Accessories',   55.00),
    ('Nike Air Jordan 1',      'Fashion',      160.00),
    ('Adidas Ultraboost',      'Fashion',      180.00),
    ('Casio G-Shock',          'Fashion',       95.00),
    ('Samsonite Backpack',     'Fashion',       75.00),
    ('Desk Lamp LED',          'Home',          35.00),
    ('Wireless Earbuds',       'Electronics',   69.00),
    ('Gaming Mouse Pad XL',    'Accessories',   29.00),
    ('Standing Desk Converter','Furniture',    320.00),
    ('USB-C Hub 7-in-1',       'Accessories',   49.00),
    ('External SSD 1TB',       'Computers',    120.00),
    ('Mechanical Keyboard RGB','Accessories',  110.00),
    ('Smart Watch',            'Fashion',      199.00),
    ('Coffee Maker',           'Home',          85.00),
    ('Blender 1000W',          'Home',         120.00),
    ('Yoga Mat Premium',       'Fashion',       45.00),
    ('Water Bottle 1L',        'Fashion',       25.00),
    ('Webcam 4K',              'Accessories',  139.00),
    ('Monitor 27" 144Hz',      'Computers',    350.00);

-- 3. Inventory for all 30 products
INSERT INTO Inventory (product_id, quantity_on_hand)
VALUES
    (1,45),(2,32),(3,18),(4,25),(5,22),(6,28),(7,120),(8,80),(9,12),(10,35),
    (11,90),(12,150),(13,70),(14,65),(15,95),(16,110),(17,60),(18,200),(19,85),(20,40),
    (21,130),(22,55),(23,70),(24,45),(25,100),(26,80),(27,60),(28,90),(29,75),(30,50);

-- 4. 120 Orders (Jan–Mar 2025) — All Pending
INSERT INTO `Order` (customer_id, order_date, total_amount, order_status)
VALUES
    (1,'2025-01-05',0,'Pending'),  (2,'2025-01-06',0,'Pending'),  (3,'2025-01-07',0,'Pending'),  (4,'2025-01-08',0,'Pending'),  (5,'2025-01-09',0,'Pending'),
    (6,'2025-01-10',0,'Pending'),  (7,'2025-01-11',0,'Pending'),  (8,'2025-01-12',0,'Pending'),  (9,'2025-01-13',0,'Pending'),  (10,'2025-01-14',0,'Pending'),
    (11,'2025-01-15',0,'Pending'), (12,'2025-01-16',0,'Pending'), (13,'2025-01-17',0,'Pending'), (14,'2025-01-18',0,'Pending'), (15,'2025-01-19',0,'Pending'),
    (16,'2025-01-20',0,'Pending'), (17,'2025-01-21',0,'Pending'), (18,'2025-01-22',0,'Pending'), (19,'2025-01-23',0,'Pending'), (20,'2025-01-24',0,'Pending'),
    (21,'2025-01-25',0,'Pending'), (22,'2025-01-26',0,'Pending'), (23,'2025-01-27',0,'Pending'), (24,'2025-01-28',0,'Pending'), (25,'2025-01-29',0,'Pending'),

    (1,'2025-02-01',0,'Pending'),  (2,'2025-02-02',0,'Pending'),  (5,'2025-02-03',0,'Pending'),  (8,'2025-02-04',0,'Pending'),  (11,'2025-02-05',0,'Pending'),
    (14,'2025-02-06',0,'Pending'), (17,'2025-02-07',0,'Pending'), (20,'2025-02-08',0,'Pending'), (23,'2025-02-09',0,'Pending'), (3,'2025-02-10',0,'Pending'),
    (6,'2025-02-11',0,'Pending'),  (9,'2025-02-12',0,'Pending'),  (12,'2025-02-13',0,'Pending'), (15,'2025-02-14',0,'Pending'), (18,'2025-02-15',0,'Pending'),
    (21,'2025-02-16',0,'Pending'), (24,'2025-02-17',0,'Pending'), (4,'2025-02-18',0,'Pending'),  (7,'2025-02-19',0,'Pending'),  (10,'2025-02-20',0,'Pending'),
    (13,'2025-02-21',0,'Pending'), (16,'2025-02-22',0,'Pending'), (19,'2025-02-23',0,'Pending'), (22,'2025-02-24',0,'Pending'), (25,'2025-02-25',0,'Pending'),

    (1,'2025-03-01',0,'Pending'),  (3,'2025-03-02',0,'Pending'),  (5,'2025-03-03',0,'Pending'),  (7,'2025-03-04',0,'Pending'),  (9,'2025-03-05',0,'Pending'),
    (11,'2025-03-06',0,'Pending'), (13,'2025-03-07',0,'Pending'), (15,'2025-03-08',0,'Pending'), (17,'2025-03-09',0,'Pending'), (19,'2025-03-10',0,'Pending'),
    (21,'2025-03-11',0,'Pending'), (23,'2025-03-12',0,'Pending'), (2,'2025-03-13',0,'Pending'),  (4,'2025-03-14',0,'Pending'),  (6,'2025-03-15',0,'Pending'),
    (8,'2025-03-16',0,'Pending'),  (10,'2025-03-17',0,'Pending'), (12,'2025-03-18',0,'Pending'), (14,'2025-03-19',0,'Pending'), (16,'2025-03-20',0,'Pending'),
    (18,'2025-03-21',0,'Pending'), (20,'2025-03-22',0,'Pending'), (22,'2025-03-23',0,'Pending'), (24,'2025-03-24',0,'Pending'), (1,'2025-03-25',0,'Pending'),
    (2,'2025-03-26',0,'Pending'),  (5,'2025-03-27',0,'Pending'),  (10,'2025-03-28',0,'Pending'), (15,'2025-03-29',0,'Pending'), (20,'2025-03-30',0,'Pending');


-- 5. 300 OrderItems randomly assigned to Orders and Products
-- for 120 orders, assigning at least 1 item per order
INSERT INTO OrderItem (order_id, product_id, quantity)
SELECT seq AS order_id,
       FLOOR(1 + RAND() * 30) AS product_id,
       FLOOR(1 + RAND() * 5) AS quantity
FROM (
    SELECT @row := @row + 1 AS seq
    FROM information_schema.columns,
         (SELECT @row := 0) AS init
    LIMIT 80
) AS numbers;


-- Add extra random items for variety
INSERT INTO OrderItem(order_id, product_id, quantity)
SELECT FLOOR(1 + RAND()*80), FLOOR(1 + RAND()*30), FLOOR(1 + RAND()*5)
FROM information_schema.tables
LIMIT 180; -- adds 180 more random items



-- 7. Manually set a few statuses for realism
UPDATE `Order` SET order_status = 'Delivered' WHERE order_id BETWEEN 1 AND 60;
UPDATE `Order` SET order_status = 'Shipped'   WHERE order_id BETWEEN 61 AND 90;
UPDATE `Order` SET order_status = 'Cancelled' WHERE order_id IN (6,16,26,36,51,66,81,106);