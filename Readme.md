# Project Documentation

## Table of Contents
1. Introduction  
2. Project Structure  
3. ER Diagram Documentation  
    3.1 Overview  
    3.2 ER Diagram  
    3.3 Entity Summaries  
    3.4 Relationship and Cardinality Rules  
    3.5 Notes on Keys and Design Decisions  
4. Database Initialization Guide  
    4.1 SQL File Structure (ddl, dml, docker_init)  
    4.2 Automated SQL Generation  
    4.3 Using the generate_docker_init.sh Script  
5. Docker Environment Setup  
    5.1 MySQL Service  
    5.2 phpMyAdmin Service  
6. Accessing the Database  
    6.1 Starting Docker  
    6.2 Entering the MySQL Container  
    6.3 Connecting to the MySQL Shell  
7. Additional Notes and Best Practices  

---

# 1. Introduction

This document provides the full architectural, structural, and operational documentation for the project.  
It explains the Entity-Relationship model, directory structure, SQL initialization approach, Docker setup, and instructions for accessing the database.

---

# 2. Project Structure

```

project_root/
│
├── README.md
│
├── er_diagram/
│   ├── er_diagram.puml
│   └── er_diagram.png
│  
│
├── sql/
│   ├── ddl/
│   │   ├── create_tables.sql
│   │   ├── constraints.sql
│   │   └── indexes.sql
│   │
│   ├── dml/
│   │   ├── sample_data.sql
│   │   └── update_inventory.sql
│   │
│   ├── queries/
│   │   ├── kpi_queries.sql
│   │   └── analytical_queries.sql
│   │   
│   │
│   └── utils/
│       └── cleanup.sql
│
├── sql/docker_init/   (auto-generated)
│   ├── 01_ddl_create_tables.sql
│   ├── 02_ddl_constraints.sql
│   ├── 03_ddl_indexes.sql
│   ├── 04_dml_sample_data.sql
│   ├── 05_dml_update_inventory.sql
│
|
│
├── generate_docker_init.sh
└── docker-compose.yml

```

---

# 3. ER Diagram Documentation

This document provides an overview of the Entity-Relationship (ER) Diagram used in the project.
It explains the data model, core entities, relationships, and cardinality rules that guide the database design.

---

## 3.1 Overview

The ER diagram represents the **conceptual and physical structure** of the system’s database.
It captures the key business objects, such as **Customer**, **Order**, **Product**, **OrderItem**, and **Inventory**, and illustrates how these entities interact with one another.

The model ensures:

* Clear entity definitions
* Proper use of primary keys and foreign keys
* Accurate representation of cardinalities (e.g., one-to-many, many-to-many resolved via a junction table, one-to-one where appropriate)
* Conformance to normalization and relational database standards

---

## 3.2 ER Diagram

![ER Diagram ](./er_diagram/er_diagram.png)

---

## 3.3 File Location

All ER-diagram–related assets are stored in the **`er_diagram/`** folder, including:

* The **PlantUML code** used to generate the diagram
* The **rendered ER diagram image** 

PlantUML code was used to make updating the ER diagram easy as the database design evolves.

PlantUML allows the diagram to be updated quickly whenever changes are made to the database design.


---

## 3.4 Summary of Entities & Relationships

### **Customer**

Represents individuals placing orders.
Participates in a **1-to-many** relationship with Order (a customer can place zero or many orders).

### **Order**

Represents a purchase transaction.
Must include **at least one OrderItem**, forming a **1-to-many** relationship.

### **Product**

Represents purchasable items in the system.
Can appear in zero or many OrderItems, depending on whether it has ever been sold.

### **Inventory**

Tracks the current available stock for each product.
Uses a **one-to-one relationship** with Product, where:

* Every product has exactly one inventory record
* The `product_id` serves as both the **primary key** and a **foreign key**
* Helps ensure accurate stock management for order processing

### **OrderItem**

Serves as the **junction (associative) entity** linking Orders and Products.
Implements the many-to-many relationship by storing:

* Product ID
* Order ID
* Quantity
* Purchase price at the time of order

**Surrogate Key Explanation:**

* Although `OrderItem` has a **composite key** (`order_id`, `product_id`), we also include a **surrogate key (`order_item_id`)** to:

  * Simplify indexing and joins
  * Support future extensibility (e.g., referencing specific line items from other tables)
  * Improve performance on large datasets
* The surrogate key supplements the composite key for a cleaner and more maintainable physical model.

---

## Cardinality Notes

* **Customer to Order:** Zero or Many

  * **Minimum:** 0, a newly registered customer may have no orders yet
  * **Maximum:** many, a customer can place multiple orders over time

* **Order to OrderItem:** One or Many

  * **Minimum:** 1, an order must contain at least one product
  * **Maximum:** many, an order can contain several different items

* **Product to OrderItem:** Zero or Many

  * **Minimum:** 0  a product might not appear in any order
  * **Maximum:** many, a product can be part of multiple order items

* **Product to Inventory:** Exactly One to Exactly One

  * **Minimum/Maximum Product side:** 1, every product must have a stock record
  * **Minimum/Maximum Inventory side:** 1, each inventory entry corresponds to a single product
  * Ensures strong consistency for stock tracking



## 3.3 Entity Summaries

### Customer  
Represents individuals who place orders.  
Each customer may have multiple orders over time, but a new customer may have none yet.

### Order  
Represents a purchase activity.  
An order must contain at least one OrderItem.  
Each order is linked to exactly one customer.

### Product  
Represents items the business sells.  
A product may or may not appear in an order depending on whether it has been purchased before.

### Inventory  
Tracks the available stock for each product.  
Each product is associated with exactly one inventory record.  
The relationship is enforced by sharing the same primary key.

### OrderItem  
Represents an item within an order.  
It resolves the many-to-many relationship between Order and Product.  
Stores product ID, order ID, quantity, and price at the time of purchase.

---

## 3.4 Relationship and Cardinality Rules

### Customer to Order  
- Zero or Many  
A customer may have no orders or many over time.

### Order to OrderItem  
- One or Many  
An order must contain at least one item.

### Product to OrderItem  
- Zero or Many  
A product may appear in no orders or in many.

### Product to Inventory  
- One to One  
Each product must have exactly one inventory record.

---

## 3.5 Notes on Keys and Design Decisions

### Use of Surrogate Keys  
The OrderItem table contains a surrogate key (`order_item_id`) even though a composite key (`order_id`, `product_id`) could uniquely identify each row.  
This improves performance and simplifies joins and future extensions.

### Normalization  
The database is normalized to ensure data integrity and eliminate redundancy.

### Triggers and Procedures  
Triggers automate updates to order totals and inventory.  
Procedures encapsulate business logic such as updating totals and adjusting stock.

---

# 4. Database Initialization Guide

## 4.1 SQL File Structure

The SQL files are divided into:

### ddl/  
Contains Data Definition Language files:
- Table creation  
- Constraints  
- Indexes  

### dml/  
Contains Data Manipulation Language files:
- Sample data  
- Data updates  

### docker_init/  
Contains auto-generated SQL files prefixed so Docker loads them in the correct order.

---

## 4.2 Automated SQL Generation

The `generate_docker_init.sh` script scans:

- `sql/ddl/`  
- `sql/dml/`  

and creates a correctly ordered list of SQL files in:

```bash

sql/docker_init/

```

This ensures MySQL executes the SQL files in sequence during container startup.

---

## 4.3 Using the generate_docker_init.sh Script

### Step 1: Make the script executable

```bash

chmod +x generate_docker_init.sh

```

### Step 2: Run the script

```bash

./generate_docker_init.sh

```

This regenerates the docker_init folder based on the latest ddl and dml files.

### Step 3: Start Docker

```bash

docker-compose up -d

```

---

# 5. Docker Environment Setup

## 5.1 MySQL Service

The MySQL container:
- Loads environment variables from `.env`
- Executes SQL files from `sql/docker_init/`
- Writes logs to the mounted `logs/` directory
- Enables general, slow, and error logging for debugging and optimization

## 5.2 phpMyAdmin Service

phpMyAdmin provides a browser interface for database management.

It runs at:


[http://localhost:8080](http://localhost:8080)


It uses MySQL service name (`mysql`) to connect internally within Docker.

---

# 6. Accessing the Database

## 6.1 Start Docker

```bash

docker-compose up -d

```

## 6.2 Enter the MySQL Container

```bash

docker exec -it ecommerce_project bash

```

## 6.3 Connect to MySQL Shell

```bash

mysql -u <your_mysql_user> -p

```

Use the password from your `.env` file.

Example commands once connected:

```sql

SHOW DATABASES;
USE <your_database_name>;
SELECT * FROM Customer;

```

---

# 7. Additional Notes and Best Practices

- Always regenerate the docker_init folder whenever ddl or dml files change.
- Avoid placing SQL files directly under docker_init manually.
- Use consistent naming conventions across SQL files.
- Use phpMyAdmin or MySQL CLI for testing queries.
- Keep ER diagrams updated whenever structural database changes occur.
- Maintain normalization to avoid data redundancy.
- Keep business logic in stored procedures and triggers to maintain consistency.



