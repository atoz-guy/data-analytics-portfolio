# Balboa Utility Migration Risk Monitor

A series of SQL labs that simulate the data validation work done when a utility moves customer data from a legacy Customer Information System (CIS) to a modern platform such as SAP. Each lab finds a different kind of migration risk, checks it with SQL, and documents the results the way a consulting validation report would.

> Independent learning project. Not affiliated with or endorsed by Balboa Bay Partners. All data is fictional. 

## SQL Labs

| Lab | Topic | Key Skills | Status |
|---|---|---|---|
| [Lab 01](sql-labs/Balboa_Lab01_Account_Validation.sql) | Account Reconciliation & Validation | `LEFT JOIN` reconciliation, `IS NULL` exception detection | Complete |
| [Lab 02](sql-labs/Balboa_Lab02_Account_Status_Validation.sql) | Account Status Validation | Data profiling, `TRIM`, `LEN` vs `DATALENGTH`, safe `UPDATE`s, before/after change log | Complete |
| [Lab 03](sql-labs/Balboa_Lab03_Migration_Exception_Report.sql) | Migration Exception Report | `CASE WHEN` classification, exception tracking table, guarded status `UPDATE`s, multi-table `JOIN` validation | Complete |
| [Lab 04](sql-labs/Balboa_Lab04_Control_Validation.sql) | Migration Risk & Control Validation | Control testing, `GROUP BY CASE` summaries, pass-rate math with `NULLIF`, remediation tracking table, `BIT` verification gates, `UPDATE ... FROM ... JOIN` | Complete |
| Lab 05 (`Balboa_Lab05_Risk_Scoring.sql`) | Risk Scoring | | Planned |
| Lab 06 (`Balboa_Lab06_Remediation_Tracking.sql`) | Remediation Tracking | | Planned |
| Lab 07 (`Balboa_Lab07_Management_Reporting.sql`) | Management Reporting | | Planned |

### Lab 01: Account Reconciliation & Validation
I compared the account IDs in the legacy and target systems to see which accounts were missing and which showed up unexpectedly.

**Key finding:** Both systems had four records, but account 1003 was missing from the target and account 1005 showed up unexpectedly. If I had only checked the row counts, I would have missed both.

### Lab 02: Account Status Validation
I checked the legacy status values for abbreviations, typos, and extra spaces. I cleaned up a working copy so I could compare the results with the original data.

**Key finding:** My first check using `<>` missed a correction (account 1005) because SQL Server treats values that differ only by trailing spaces as equal in that comparison. When I added `DATALENGTH`, the validation picked up all three corrections. You can see the difference in Steps 19 and 20.

### Lab 03: Migration Exception Report
I found that account 1002 was Active in the legacy data and Inactive in the target. I logged the mismatch and tracked it from investigation through approval and resolution.

**Key finding:** In the simulated investigation, the account had been canceled with authorization after the migration snapshot. That explained the mismatch, so I resolved the exception without changing the customer data. The SQL also checked that each step was complete before moving to the next. For example, closure required both an approver and an approval reference. The evidence and approvals were simulated.

### Lab 04: Migration Risk & Control Validation
I tested C-001, which requires a documented approval reference for every resolved exception. Of the four exceptions I reviewed, two passed, one failed, and one didn't apply. That gave me a 66.67% pass rate across the three exceptions the control applied to.

**Key finding:** EXC-002 failed because its original approval wasn't documented. I tracked the fix under REM-001 and closed it after confirming the corrective control was in place and had been independently tested. I left the original approval reference blank (`NULL`), so the report still shows **Historical Control Failure** and **Not Documented**. An auditor can see what was missing at the time and what was done to fix it. All approvals and verifications were simulated.

## Documentation

- [Business Requirements](documentation/Business_Requirements.md): what the validation work must prove, and what's in and out of scope
- [Data Dictionary](documentation/Data_Dictionary.md): every table and column used in the labs

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
├── documentation/   Business requirements and data dictionary
└── evidence/        Query result screenshots (coming soon)
```

## How to Run

The labs use SQL Server temporary tables (`#table`), so they need no database setup. Open any `.sql` file in SSMS or Azure Data Studio and run it top to bottom. Each step lists its expected result in the comments.

*Requires SQL Server 2017+ (for `TRIM()`).*
