-- Finds the id of the ONE product whose name matches the text.
-- Shows: NO_DATA_FOUND and TOO_MANY_ROWS
CREATE OR REPLACE FUNCTION fn_find_product_id (
  p_name_like IN VARCHAR2
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT product_id INTO v_id
    FROM products
   WHERE UPPER(product_name) LIKE UPPER(p_name_like);
  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20051, 'No product matches "' || p_name_like || '".');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20052, 'More than one product matches "' || p_name_like || '".');
END fn_find_product_id;
/
SHOW ERRORS
