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

## Notes

* This document is a **partial README** focused solely on the ER diagram and the database structure behind it.
* A full project README will integrate this section along with setup instructions, schema files, Docker configuration, and application logic.
