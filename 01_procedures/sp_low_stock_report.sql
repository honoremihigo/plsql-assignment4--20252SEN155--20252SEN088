-- Prints products that are at or below their reorder level.
-- Shows: explicit cursor (OPEN / FETCH / CLOSE), user-defined record, VARRAY
CREATE OR REPLACE PROCEDURE sp_low_stock_report (
  p_low_count OUT NUMBER
) IS
  -- user-defined record: one variable that holds one row of our report
  TYPE t_low_rec IS RECORD (
    product_id     products.product_id%TYPE,
    product_name   products.product_name%TYPE,
    qty_in_stock   products.qty_in_stock%TYPE,
    reorder_level  products.reorder_level%TYPE
  );
  v_row t_low_rec;

  -- VARRAY: a list that can hold at most 3 names (the 3 most urgent products)
  TYPE t_top_list IS VARRAY(3) OF VARCHAR2(100);
  v_top t_top_list := t_top_list();

  CURSOR c_low IS
    SELECT product_id, product_name, qty_in_stock, reorder_level
      FROM products
     WHERE status = 'ACTIVE' AND qty_in_stock <= reorder_level
     ORDER BY qty_in_stock;
BEGIN
  p_low_count := 0;

  OPEN c_low;
  LOOP
    FETCH c_low INTO v_row;
    EXIT WHEN c_low%NOTFOUND;

    p_low_count := p_low_count + 1;
    DBMS_OUTPUT.PUT_LINE(v_row.product_id || ' ' || v_row.product_name ||
                         ' | stock ' || v_row.qty_in_stock ||
                         ' | reorder level ' || v_row.reorder_level);

    IF v_top.COUNT < v_top.LIMIT THEN       -- keep only the first 3
      v_top.EXTEND;
      v_top(v_top.COUNT) := v_row.product_name;
    END IF;
  END LOOP;
  CLOSE c_low;

  DBMS_OUTPUT.PUT_LINE('Total low stock products: ' || p_low_count);
  FOR i IN 1 .. v_top.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('Most urgent #' || i || ': ' || v_top(i));
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF c_low%ISOPEN THEN
      CLOSE c_low;
    END IF;
    RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in sp_low_stock_report: ' || SQLERRM);
END sp_low_stock_report;
/
SHOW ERRORS
