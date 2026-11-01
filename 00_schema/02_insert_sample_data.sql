-- Sample data (plain INSERT statements). Run after 01_create_tables.sql

--suppliers--
INSERT INTO suppliers (supplier_name, city) VALUES ('Kigali Tech Supplies', 'Kigali');
INSERT INTO suppliers (supplier_name, city) VALUES ('Rwanda Office Depot',  'Kigali');
INSERT INTO suppliers (supplier_name, city) VALUES ('Musanze Trading Co',   'Musanze');

--products--
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Laptop',             1, 650.00,  15,   5, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Wireless Mouse',     1,  12.50,   3,  10, 'ACTIVE');   -- low stock
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Keyboard',           1,  20.00,  40,  10, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('A4 Paper Ream',      2,   5.00,   8,  20, 'ACTIVE');   -- low stock
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Ballpoint Pens Box', 2,   3.00, 100,  30, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Stapler',            2,   7.50,  25,   5, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Office Chair',       3,  85.00,   4,   5, 'ACTIVE');   -- low stock
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Desk',               3, 150.00,  12,   3, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Rice 50kg Bag',      3,  40.00, 480, 490, 'ACTIVE');   -- low stock, almost full
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Cooking Oil 20L',    3,  30.00,  60,  15, 'ACTIVE');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Old Printer',        1, 100.00,   0,   0, 'DISCONTINUED');
INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock, reorder_level, status) VALUES ('Old Scanner',        2,  90.00,   0,   0, 'DISCONTINUED');

-- stock movements
INSERT INTO stock_movements (product_id, movement_type, quantity) VALUES (1, 'IN', 15);
INSERT INTO stock_movements (product_id, movement_type, quantity) VALUES (3, 'IN', 40);
INSERT INTO stock_movements (product_id, movement_type, quantity) VALUES (5, 'IN', 100);
INSERT INTO stock_movements (product_id, movement_type, quantity) VALUES (2, 'OUT', 7);

COMMIT;
