-- Adds p_add_qty units to every low-stock product of one supplier, all at once.
-- Shows: nested table, BULK COLLECT, FORALL, SAVE EXCEPTIONS (bulk DML errors),
--        SQL%BULK_EXCEPTIONS, user-defined exception
CREATE OR REPLACE PROCEDURE sp_bulk_restock (
  p_supplier_id IN  NUMBER,
  p_add_qty     IN  NUMBER,
  p_updated     OUT NUMBER,
  p_failed      OUT NUMBER
) IS
  TYPE t_id_table IS TABLE OF products.product_id%TYPE;   -- nested table
  v_ids t_id_table;

  e_bad_qty     EXCEPTION;
  e_bulk_errors EXCEPTION;                                -- Oracle error -24381
  PRAGMA EXCEPTION_INIT (e_bulk_errors, -24381);
BEGIN
  p_updated := 0;
  p_failed  := 0;

  IF p_add_qty <= 0 THEN
    RAISE e_bad_qty;
  END IF;

  -- BULK COLLECT: read all matching product ids into the collection in ONE step
  SELECT product_id BULK COLLECT INTO v_ids
    FROM products
   WHERE supplier_id = p_supplier_id
     AND status = 'ACTIVE'
     AND qty_in_stock <= reorder_level;

  IF v_ids.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('No low stock products for supplier ' || p_supplier_id);
    RETURN;
  END IF;

  BEGIN
    -- FORALL: update all those products in ONE step.
    -- SAVE EXCEPTIONS: if one row fails, carry on with the others.
    FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
      UPDATE products
         SET qty_in_stock = qty_in_stock + p_add_qty
       WHERE product_id = v_ids(i);

    p_updated := SQL%ROWCOUNT;
  EXCEPTION
    WHEN e_bulk_errors THEN
      p_failed  := SQL%BULK_EXCEPTIONS.COUNT;
      p_updated := v_ids.COUNT - p_failed;
      FOR j IN 1 .. p_failed LOOP
        DBMS_OUTPUT.PUT_LINE('FAILED product ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) ||
                             ' -> ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
      END LOOP;
  END;

  DBMS_OUTPUT.PUT_LINE('Updated: ' || p_updated || ', failed: ' || p_failed);
  COMMIT;
EXCEPTION
  WHEN e_bad_qty THEN
    RAISE_APPLICATION_ERROR(-20060, 'Quantity to add must be greater than zero.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in sp_bulk_restock: ' || SQLERRM);
END sp_bulk_restock;
/
SHOW ERRORS
