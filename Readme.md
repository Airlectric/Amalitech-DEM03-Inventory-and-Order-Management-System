# ER Diagram Documentation

This document provides an overview of the Entity-Relationship (ER) Diagram used in the project.
It explains the data model, core entities, relationships, and cardinality rules that guide the database design.

---

## Overview

The ER diagram represents the **conceptual and physical structure** of the system’s database.
It captures the key business objects, such as **Customer**, **Order**, **Product**, **OrderItem**, and **Inventory**, and illustrates how these entities interact with one another.

The model ensures:

* Clear entity definitions
* Proper use of primary keys and foreign keys
* Accurate representation of cardinalities (e.g., one-to-many, many-to-many resolved via a junction table, one-to-one where appropriate)
* Conformance to normalization and relational database standards

---

## ER Diagram

![ER Diagram ](./er_diagram/er_diagram.png)

---

## File Location

All ER-diagram–related assets are stored in the **`er_diagram/`** folder, including:

* The **PlantUML code** used to generate the diagram
* The **rendered ER diagram image** (PNG/SVG)

PlantUML code was used to make updating the ER diagram easy as the database design evolves.

---

## Summary of Entities & Relationships

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

---



# **Database Initialization & Access Guide**

This guide explains:

* How to generate and organize your `ddl/` and `dml/` SQL files for Docker.
* How to access the MySQL database inside your running Docker container.

---

## **1. Generating Docker-Ready SQL Initialization Files**

Whenever you update your `ddl/` or `dml/` folders, regenerate the `docker_init/` folder so Docker loads SQL files in the correct order.

### **Step 1: Make the Script Executable**

```bash
chmod +x generate_docker_init.sh
```

### **Step 2: Run the Script**

```bash
./generate_docker_init.sh
```

This automatically builds the proper `docker_init/` folder from your `ddl/` and `dml/` files.

### **Step 3: Start Docker**

```bash
docker-compose up -d
```

Your MySQL container will now load the SQL files correctly without manual copying.

---

## **2. How to Access MySQL Inside the Docker Container**

### **Step 1: Start Containers**

```bash
docker-compose up -d
```

Runs everything in the background.

### **Step 2: Enter the MySQL Container**

```bash
docker exec -it ecommerce_project bash
```

Your prompt will change:

```
root@<container_id>:/#
```

You are now inside the container.

### **Step 3: Connect to MySQL**

```bash
mysql -u ecommerce_user -p
```

Use the username from your `.env` file.

### **Step 4: Enter Your Password**

You’ll be prompted for the password from `.env`.

Once successful, you’ll see:

```
mysql>
```

You can now run SQL queries.

Example:

```sql
SHOW DATABASES;
USE ecommerce_db;
SELECT * FROM Customer;
```

