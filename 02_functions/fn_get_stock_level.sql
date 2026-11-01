-- Returns the quantity in stock of one product.
-- Shows: NO_DATA_FOUND, RAISE_APPLICATION_ERROR (error is not hidden)
CREATE OR REPLACE FUNCTION fn_get_stock_level (
  p_product_id IN NUMBER
) RETURN NUMBER IS
  v_qty NUMBER;
BEGIN
  SELECT qty_in_stock INTO v_qty FROM products WHERE product_id = p_product_id;
  RETURN v_qty;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20050, 'Product ' || p_product_id || ' not found.');
END fn_get_stock_level;
/
SHOW ERRORS
