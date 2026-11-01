CREATE OR REPLACE PROCEDURE sp_issue_stock (
  p_product_id IN  NUMBER,
  p_quantity   IN  NUMBER,
  p_remaining  OUT NUMBER
) IS
  v_prod products%ROWTYPE;                 -- a record with the same columns as the products table
  e_invalid_qty        EXCEPTION;
  e_insufficient_stock EXCEPTION;
BEGIN
  IF p_quantity <= 0 THEN
    RAISE e_invalid_qty;
  END IF;

  SELECT * INTO v_prod FROM products WHERE product_id = p_product_id;   -- may raise NO_DATA_FOUND

  IF v_prod.qty_in_stock < p_quantity THEN
    RAISE e_insufficient_stock;
  END IF;

  UPDATE products
     SET qty_in_stock = qty_in_stock - p_quantity
   WHERE product_id = p_product_id;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Rows updated: ' || SQL%ROWCOUNT);
    INSERT INTO stock_movements (product_id, movement_type, quantity)
    VALUES (p_product_id, 'OUT', p_quantity);
  END IF;

  p_remaining := v_prod.qty_in_stock - p_quantity;
  COMMIT;
EXCEPTION
  WHEN e_invalid_qty THEN
    RAISE_APPLICATION_ERROR(-20010, 'Quantity must be greater than zero.');
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20011, 'Product ' || p_product_id || ' does not exist.');
  WHEN e_insufficient_stock THEN
    RAISE_APPLICATION_ERROR(-20012, 'Not enough stock. Requested ' || p_quantity ||
                            ', available ' || v_prod.qty_in_stock);
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in sp_issue_stock: ' || SQLERRM);
END sp_issue_stock;
/
SHOW ERRORS
