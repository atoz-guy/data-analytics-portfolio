# Data Dictionary

Every table and column used in the SQL labs. All tables are SQL Server temporary tables (`#table`) that exist only while the lab runs. All data is fictional.

## Lab 01: Account Reconciliation & Validation

### `#Legacy_Accounts`
Customer accounts as they exist in the legacy CIS before migration.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |

Sample data: 4 rows (1001, 1002, 1003, 1004).

### `#Target_Accounts`
Customer accounts as they exist in the target platform after migration.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |

Sample data: 4 rows (1001, 1002, 1004, 1005).

## Lab 02: Account Status Validation

### `#Legacy_Status`
Original legacy status values, including data quality problems. Never modified.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |
| `Account_Status` | `VARCHAR(20)` | Account status as stored in the legacy system |

Sample data: 6 rows, with an abbreviation (`A`), a typo (`Actve`) and a trailing space (`Active `).

### `#Legacy_Status_Corrected`
Working copy of `#Legacy_Status` (created with `SELECT ... INTO`). All corrections are applied here.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |
| `Account_Status` | `VARCHAR(20)` | Corrected account status |

**Approved status values:** `Active`, `Inactive`, `Suspended`.

## Lab 03: Migration Exception Report

### `#Legacy_Accounts_Lab03`
Legacy account statuses before migration.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |
| `Account_Status` | `VARCHAR(20)` | Legacy status (`Active` / `Inactive`) |

### `#Target_Accounts_Lab03`
Target account statuses after migration.

| Column | Type | Description |
|---|---|---|
| `Account_ID` | `INT` | Customer account number |
| `Account_Status` | `VARCHAR(20)` | Target status (`Active` / `Inactive`) |

### `#Migration_Exceptions`
Exception tracking record, stored separately from customer data. One row per discrepancy.

| Column | Type | Description |
|---|---|---|
| `Exception_ID` | `VARCHAR(10)` | Primary key, for example `EXC-001` |
| `Account_ID` | `INT` | Account the exception relates to |
| `Discrepancy_Type` | `VARCHAR(50)` | Type of issue, for example `Status Mismatch` |
| `Exception_Status` | `VARCHAR(30)` | Lifecycle stage: `Open` → `Under Investigation` → `Resolved` |
| `Recommended_Action` | `VARCHAR(150)` | Suggested next step for the investigator |
| `Evidence_Reference` | `VARCHAR(100)` | ID of the supporting evidence (fictional in this lab) |
| `Investigation_Findings` | `VARCHAR(500)` | What the investigation found so far |
| `Resolution_Decision` | `VARCHAR(200)` | Outcome, for example `No account correction required` |
| `Resolution_Reason` | `VARCHAR(500)` | Why that decision was made |
| `Resolution_Status` | `VARCHAR(30)` | Approval stage: `Pending Approval` → `Approved` |
| `Approved_By` | `VARCHAR(100)` | Role that approved the resolution (simulated) |
| `Approval_Reference` | `VARCHAR(100)` | Approval ID, for example `APP-EXC-001` |

**Calculated columns (not stored):** `Discrepancy_Type`, `Expected_Target_Status`, `Recommended_Action` and `Exception_Status` are also produced with `CASE WHEN` in Steps 5–9 before the exception table exists.

## Labs 04–07

Tables will be added here as each lab is written.
