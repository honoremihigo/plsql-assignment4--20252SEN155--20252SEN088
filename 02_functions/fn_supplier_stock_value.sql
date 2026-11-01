-- Total value of the stock (quantity x price) held for one supplier.
-- Shows: local variables, SQL aggregate, function used inside a SELECT
CREATE OR REPLACE FUNCTION fn_supplier_stock_value (
  p_supplier_id IN NUMBER
) RETURN NUMBER IS
  v_name  suppliers.supplier_name%TYPE;
  v_total NUMBER;
BEGIN
  SELECT supplier_name INTO v_name FROM suppliers WHERE supplier_id = p_supplier_id;

  SELECT NVL(SUM(qty_in_stock * unit_price), 0) INTO v_total
    FROM products
   WHERE supplier_id = p_supplier_id;

  RETURN v_total;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20053, 'Supplier ' || p_supplier_id || ' not found.');
END fn_supplier_stock_value;
/
SHOW ERRORS
