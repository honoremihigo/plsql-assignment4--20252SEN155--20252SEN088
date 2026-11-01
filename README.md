# Inventory Control System (Oracle PL/SQL) - Group Assignment IV

Course: Database Development with PL/SQL (INSY 8311)

## Group members
| Name | Student ID |
|------|-----------|
| Hirwa Mihigo Honore | 20252SEN088 |
| Isimbi Queen | 20252SEN155 |

## Application description
A small inventory system for a shop or store. Products come from suppliers. Every time stock is
sold or received it is recorded. The system must:
- add new products and reject bad data (duplicate id, wrong price, unknown supplier),
- remove stock when items are issued, and never allow stock to go below zero,
- show which products are low on stock,
- restock all low-stock products of one supplier in one bulk operation,
- delete discontinued products.

## Database (00_schema)
Tables: `suppliers`, `products`, `stock_movements` (and `perf_test` for the speed test).
Relationships: one supplier has many products; one product has many stock movements.
Primary keys are identity columns (Oracle generates the ids). Constraints: primary keys, foreign keys, NOT NULL, UNIQUE, CHECK (price > 0, status values,
quantity between 0 and 500, movement type IN/OUT), DEFAULT values.

## Code (5 procedures, 3 functions)
| File | What it does | Concepts shown |
|------|--------------|----------------|
| `sp_add_product` | adds a product (id is auto-generated) | implicit cursor INSERT, RETURNING INTO, user-defined exception, DUP_VAL_ON_INDEX |
| `sp_issue_stock` | removes stock | `%ROWTYPE` record, implicit cursor UPDATE, NO_DATA_FOUND, OUT parameter |
| `sp_delete_discontinued` | deletes discontinued products | implicit cursor DELETE, `SQL%FOUND/NOTFOUND/ROWCOUNT` |
| `sp_low_stock_report` | lists low stock products | explicit cursor OPEN/FETCH/CLOSE, user-defined record, VARRAY |
| `sp_bulk_restock` | restocks many products at once | nested table, BULK COLLECT, FORALL, SAVE EXCEPTIONS |
| `fn_get_stock_level` | stock of a product | NO_DATA_FOUND, RAISE_APPLICATION_ERROR |
| `fn_find_product_id` | find one product by name | NO_DATA_FOUND, TOO_MANY_ROWS |
| `fn_supplier_stock_value` | stock value of a supplier | used inside a SELECT |

## How to run (in this order)
1. `00_schema/01_create_tables.sql`
2. `00_schema/02_insert_sample_data.sql`
3. all files in `01_procedures/`
4. all files in `02_functions/`
5. `03_tests/test_success_cases.sql`, then `03_tests/test_error_cases.sql`

## AI usage
We used an AI assistant (Claude) to help plan the project and draft the scripts. We then read, ran and tested the code and can explain it.
