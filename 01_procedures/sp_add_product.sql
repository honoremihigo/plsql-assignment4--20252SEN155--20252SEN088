CREATE OR REPLACE PROCEDURE sp_add_product (
  p_name         IN  VARCHAR2,
  p_supplier_id  IN  NUMBER,
  p_price        IN  NUMBER,
  p_qty          IN  NUMBER,
  p_product_id   OUT NUMBER
) IS
  e_invalid_price    EXCEPTION;            
  e_supplier_missing EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_supplier_missing, -2291);
BEGIN
  IF p_price <= 0 THEN
    RAISE e_invalid_price;
  END IF;

  INSERT INTO products (product_name, supplier_id, unit_price, qty_in_stock)
  VALUES (p_name, p_supplier_id, p_price, p_qty)
  RETURNING product_id INTO p_product_id;            -- gives us the id Oracle generated

  DBMS_OUTPUT.PUT_LINE('Rows inserted: ' || SQL%ROWCOUNT || ' | new product id: ' || p_product_id);
  COMMIT;
EXCEPTION
  WHEN e_invalid_price THEN
    RAISE_APPLICATION_ERROR(-20001, 'Price must be greater than zero.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20002, 'A product named "' || p_name || '" already exists.');
  WHEN e_supplier_missing THEN
    RAISE_APPLICATION_ERROR(-20003, 'Supplier ' || p_supplier_id || ' does not exist.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in sp_add_product: ' || SQLERRM);
END sp_add_product;
/
SHOW ERRORS
