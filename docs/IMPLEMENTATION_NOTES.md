# Implementation and performance notes

## How the pieces fit together
- **Records:** `sp_issue_stock` uses `products%ROWTYPE` (a record shaped like a table row).
  `sp_low_stock_report` uses a record type we defined ourselves.
- **Collections:** a nested table holds product ids in `sp_bulk_restock`; a VARRAY holds the
  3 most urgent products in `sp_low_stock_report`.
- **Implicit cursors:** INSERT, UPDATE and DELETE are checked with `SQL%ROWCOUNT`, `SQL%FOUND`
  and `SQL%NOTFOUND`.
- **Explicit cursor:** `sp_low_stock_report` opens a cursor, fetches row by row, then closes it.
- **Exceptions:** known problems are converted into clear messages with `RAISE_APPLICATION_ERROR`
  (codes -20001 to -20060). Any other error is re-raised as -20099 with Oracle's message,
  so no error is hidden.

## Why bulk processing is faster
PL/SQL and SQL are two separate engines inside Oracle. Each SQL statement inside a PL/SQL loop
makes Oracle switch from one engine to the other and back (a *context switch*). For 20,000 rows
that is 20,000 switches.
- `BULK COLLECT` reads all rows into a collection with one switch.
- `FORALL` sends all the DML to SQL with one switch.


## Bulk errors (SAVE EXCEPTIONS)
Normally FORALL stops at the first row that fails. With `SAVE EXCEPTIONS` it continues with the
other rows and raises ORA-24381 at the end. We catch it and use `SQL%BULK_EXCEPTIONS`
(`ERROR_INDEX` = which row failed, `ERROR_CODE` = why). In test E6 the Rice product would go over
the 500 limit, so that row fails and the other product is still restocked.
