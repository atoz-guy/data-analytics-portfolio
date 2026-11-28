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
Compares legacy and target account IDs to find **missing** accounts (in legacy, not in target) and **unexpected** accounts (in target, never in legacy).

**Key finding:** both systems hold 4 records, yet their account identities don't fully match (1003 missing, 1005 unexpected). **Matching row counts don't guarantee matching customer accounts.**

### Lab 02: Account Status Validation
Profiles a status column with typical legacy data quality problems (abbreviations, typos, hidden trailing spaces), fixes a working copy while keeping the original untouched, and proves the result with validation checks.

**Key finding:** SQL Server ignores trailing spaces when comparing text, so a standard `<>` comparison **misses** a whitespace-only fix. Adding a `DATALENGTH` comparison catches all three corrections (Steps 19 vs. 20).

### Lab 03: Migration Exception Report
Detects a status mismatch between legacy and target systems (account 1002: Active → Inactive), logs it in a separate exception tracking table, and walks it through a simulated lifecycle: Open → Under Investigation → evidence and findings recorded → resolution pending approval → approved → Resolved.

**Key finding:** not every discrepancy is a migration error. The simulated investigation found an authorized cancellation after the migration snapshot, so the exception was closed with **no change to customer data**. Each status `UPDATE` only runs if the previous step is complete (for example, closure requires an approver and approval reference). All evidence and approvals are fictional.

### Lab 04: Migration Risk & Control Validation
Tests control **C-001** ("every resolved exception must have a documented approval reference") against 4 exceptions: **2 Pass, 1 Fail, 1 Not Applicable, a 66.67% pass rate**. The failure (EXC-002, account 1005) is prioritized, assigned an owner, and tracked as remediation case REM-001 through investigation, management review and an approved corrective action plan. Closure is blocked until two `BIT` verification flags (corrective control implemented, effectiveness independently tested) are both set to 1.

**Key finding:** Fixing a control failure doesn't make it go away. I closed REM-001, but I left the original approval reference blank (`NULL`) on purpose. The report still shows **Historical Control Failure** and lists the original approval as **Not Documented**. That way, an auditor can see what was missing at the time, and that it was later fixed through REM-001.

All approvals and verifications in this lab were simulated.

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
