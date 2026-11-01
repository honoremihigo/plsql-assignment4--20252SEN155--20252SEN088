-- Deletes all DISCONTINUED products.
-- Shows: implicit cursor on DELETE (SQL%FOUND, SQL%NOTFOUND, SQL%ROWCOUNT),
--        EXCEPTION_INIT for "child record found" (-2292)
CREATE OR REPLACE PROCEDURE sp_delete_discontinued (
  p_deleted OUT NUMBER
) IS
  e_has_children EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_has_children, -2292);
BEGIN
  DELETE FROM products WHERE status = 'DISCONTINUED';

  IF SQL%FOUND THEN
    p_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Products deleted: ' || p_deleted);
  ELSIF SQL%NOTFOUND THEN
    p_deleted := 0;
    DBMS_OUTPUT.PUT_LINE('No discontinued products found.');
  END IF;
  COMMIT;
EXCEPTION
  WHEN e_has_children THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20021, 'Cannot delete: a discontinued product has stock movement history.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'Unexpected error in sp_delete_discontinued: ' || SQLERRM);
END sp_delete_discontinued;
/
SHOW ERRORS
