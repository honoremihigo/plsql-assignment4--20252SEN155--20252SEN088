-- SUCCESS TESTS

SET SERVEROUTPUT ON

PROMPT ===== S1: sp_add_product =====
DECLARE
  v_new_id NUMBER;
BEGIN
  sp_add_product('USB Flash Drive', 1, 8.00, 50, v_new_id);   -- Oracle generates the id (13)
  DBMS_OUTPUT.PUT_LINE('Generated id: ' || v_new_id);
END;
/
SELECT * FROM products WHERE product_name = 'USB Flash Drive';

PROMPT ===== S2: sp_issue_stock =====
DECLARE
  v_remaining NUMBER;
BEGIN
  sp_issue_stock(1, 5, v_remaining);       -- Laptop: 15 -> 10
  DBMS_OUTPUT.PUT_LINE('Remaining stock: ' || v_remaining);
END;
/

PROMPT ===== S3: sp_low_stock_report =====
DECLARE
  v_count NUMBER;
BEGIN
  sp_low_stock_report(v_count);
END;
/

PROMPT ===== S4: sp_bulk_restock (supplier 3, add 20 units to each low stock product) =====
DECLARE
  v_updated NUMBER;
  v_failed  NUMBER;
BEGIN
  sp_bulk_restock(3, 20, v_updated, v_failed);
END;
/
SELECT product_id, product_name, qty_in_stock FROM products WHERE supplier_id = 3 ORDER BY product_id;

PROMPT ===== S5: sp_delete_discontinued (first call deletes, second finds nothing) =====
DECLARE
  v_deleted NUMBER;
BEGIN
  sp_delete_discontinued(v_deleted);
  sp_delete_discontinued(v_deleted);
END;
/

PROMPT ===== S6: functions called from a PL/SQL block =====
DECLARE
  v_id NUMBER;
BEGIN
  v_id := fn_find_product_id('Laptop');
  DBMS_OUTPUT.PUT_LINE('Laptop id: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Laptop stock: ' || fn_get_stock_level(v_id));
END;
/

PROMPT ===== S7: functions called from SQL =====
SELECT product_id, product_name, fn_get_stock_level(product_id) AS stock
  FROM products WHERE supplier_id = 1;

SELECT supplier_id, supplier_name, fn_supplier_stock_value(supplier_id) AS stock_value
  FROM suppliers;