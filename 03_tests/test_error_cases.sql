-- ERROR TESTS.

SET SERVEROUTPUT ON

PROMPT ===== E1: duplicate product name (DUP_VAL_ON_INDEX -> -20002) =====
DECLARE
  v_id NUMBER;
BEGIN
  sp_add_product('Laptop', 1, 10, 5, v_id);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E2: invalid price (user-defined exception -> -20001) =====
DECLARE
  v_id NUMBER;
BEGIN
  sp_add_product('Bad price item', 1, -5, 5, v_id);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E3: supplier does not exist (ORA-02291 -> -20003) =====
DECLARE
  v_id NUMBER;
BEGIN
  sp_add_product('No supplier item', 99, 10, 5, v_id);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E4: not enough stock (user-defined exception -> -20012) =====
DECLARE
  v_remaining NUMBER;
BEGIN
  sp_issue_stock(2, 1000, v_remaining);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E5: product does not exist (NO_DATA_FOUND -> -20011) =====
DECLARE
  v_remaining NUMBER;
BEGIN
  sp_issue_stock(999, 1, v_remaining);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E6: bulk error with SAVE EXCEPTIONS (one row breaks the 500 limit) =====
-- put supplier 3 back to its starting stock, then add 50: the Rice bag would reach 530 (limit is 500)
UPDATE products SET qty_in_stock = 4   WHERE product_id = 7;
UPDATE products SET qty_in_stock = 480 WHERE product_id = 9;
COMMIT;
DECLARE
  v_updated NUMBER;
  v_failed  NUMBER;
BEGIN
  sp_bulk_restock(3, 50, v_updated, v_failed);
END;
/
SELECT product_id, product_name, qty_in_stock FROM products WHERE supplier_id = 3 ORDER BY product_id;

PROMPT ===== E7: delete blocked because the product has movements (ORA-02292 -> -20021) =====
UPDATE products SET status = 'DISCONTINUED', qty_in_stock = 0 WHERE product_id = 3;  -- Keyboard has movements
DECLARE
  v_deleted NUMBER;
BEGIN
  sp_delete_discontinued(v_deleted);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/
ROLLBACK;

PROMPT ===== E8: function - product not found (NO_DATA_FOUND -> -20050) =====
DECLARE
  v_qty NUMBER;
BEGIN
  v_qty := fn_get_stock_level(999);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E9: function - name matches many products (TOO_MANY_ROWS -> -20052) =====
DECLARE
  v_id NUMBER;
BEGIN
  v_id := fn_find_product_id('%e%');
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E10: function - no product matches (NO_DATA_FOUND -> -20051) =====
DECLARE
  v_id NUMBER;
BEGIN
  v_id := fn_find_product_id('Spaceship');
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLERRM);
END;
/

PROMPT ===== E11: other predefined exceptions: ZERO_DIVIDE and VALUE_ERROR =====
DECLARE
  v_zero  NUMBER := 0;
  v_result NUMBER;
  v_short VARCHAR2(3);
BEGIN
  BEGIN
    v_result := 10 / v_zero;
  EXCEPTION
    WHEN ZERO_DIVIDE THEN DBMS_OUTPUT.PUT_LINE('Caught ZERO_DIVIDE: ' || SQLERRM);
  END;
  BEGIN
    v_short := 'TOO LONG FOR THREE';
  EXCEPTION
    WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Caught VALUE_ERROR: ' || SQLERRM);
  END;
END;
/
