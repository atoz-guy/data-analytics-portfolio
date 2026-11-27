# Balboa Utility Migration Risk Monitor

A series of SQL labs that simulate the data validation work done when a utility moves customer data from a legacy Customer Information System (CIS) to a modern platform such as SAP. Each lab finds a different kind of migration risk, checks it with SQL, and documents the results the way a consulting validation report would.

> Independent learning project. Not affiliated with or endorsed by Balboa Bay Partners. All data is fictional.

## SQL Labs

| Lab | Topic | Key Skills | Status |
|---|---|---|---|
| [Lab 01](sql-labs/Balboa_Lab01_Account_Validation.sql) | Account Reconciliation & Validation | `LEFT JOIN` reconciliation, `IS NULL` exception detection | Complete |
| [Lab 02](sql-labs/Balboa_Lab02_Account_Status_Validation.sql) | Account Status Validation | Data profiling, `TRIM`, `LEN` vs `DATALENGTH`, safe `UPDATE`s, before/after change log | Complete |

### Lab 01: Account Reconciliation & Validation
Compares legacy and target account IDs to find **missing** accounts (in legacy, not in target) and **unexpected** accounts (in target, never in legacy).

**Key finding:** both systems hold 4 records, yet their account identities don't fully match (1003 missing, 1005 unexpected). **Matching row counts don't guarantee matching customer accounts.**

### Lab 02: Account Status Validation
Profiles a status column with typical legacy data quality problems (abbreviations, typos, hidden trailing spaces), fixes a working copy while keeping the original untouched, and proves the result with validation checks.

**Key finding:** SQL Server ignores trailing spaces when comparing text, so a standard `<>` comparison **misses** a whitespace-only fix. Adding a `DATALENGTH` comparison catches all three corrections (Steps 19 vs. 20).

## Approach

Each lab follows the same pattern:
1. **Inspect:** look at the source data before changing anything.
2. **Detect:** write queries that surface exceptions.
3. **Correct:** fix a working copy, never the original.
4. **Validate:** prove the result with expected outcomes stated before each query.
5. **Document:** summarize findings, assumptions and limitations honestly.

## Project Structure

```
balboa-utility-migration-risk-monitor/
├── sql-labs/        SQL validation labs (T-SQL)
├── data/            Sample datasets (coming soon)
├── power-bi/        Risk dashboard (coming soon)
├── documentation/   Methodology and findings write-ups (coming soon)
└── evidence/        Query result screenshots (coming soon)
```

## How to Run

The labs use SQL Server temporary tables (`#table`), so they need no database setup. Open any `.sql` file in SSMS or Azure Data Studio and run it top to bottom. Each step lists its expected result in the comments.

*Requires SQL Server 2017+ (for `TRIM()`).*
