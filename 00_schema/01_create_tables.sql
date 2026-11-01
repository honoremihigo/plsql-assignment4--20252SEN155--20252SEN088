-- Inventory Control System: tables, relationships and constraints
-- Run this file first. It also drops old tables so you can run it again.

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
             WHERE table_name IN ('PERF_TEST','STOCK_MOVEMENTS','PRODUCTS','SUPPLIERS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

CREATE TABLE suppliers (
  supplier_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,   -- Oracle creates the id itself
  supplier_name  VARCHAR2(100) NOT NULL UNIQUE,
  city           VARCHAR2(50)
);

CREATE TABLE products (
  product_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,   -- Oracle creates the id itself
  product_name   VARCHAR2(100) NOT NULL UNIQUE,
  supplier_id    NUMBER        NOT NULL REFERENCES suppliers (supplier_id),
  unit_price     NUMBER(10,2)  NOT NULL CHECK (unit_price > 0),
  qty_in_stock   NUMBER(5)     DEFAULT 0  NOT NULL,
  reorder_level  NUMBER(5)     DEFAULT 10 NOT NULL,
  status         VARCHAR2(12)  DEFAULT 'ACTIVE' NOT NULL
                 CHECK (status IN ('ACTIVE','DISCONTINUED')),
  CONSTRAINT ck_qty_range CHECK (qty_in_stock BETWEEN 0 AND 500)   -- warehouse holds max 500
);

CREATE TABLE stock_movements (
  movement_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id     NUMBER       NOT NULL REFERENCES products (product_id),
  movement_type  VARCHAR2(3)  NOT NULL CHECK (movement_type IN ('IN','OUT')),
  quantity       NUMBER(5)    NOT NULL CHECK (quantity > 0),
  movement_date  DATE         DEFAULT SYSDATE
);

-- Small table used only to compare row-by-row and bulk speed
CREATE TABLE perf_test (
  id   NUMBER,
  qty  NUMBER
);
