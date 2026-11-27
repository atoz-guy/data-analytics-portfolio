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

## Lab 04: Migration Risk & Control Validation

### `#Control_Testing_Lab04`
Exception records tested against control C-001 (every resolved exception must have a documented approval reference). Never modified after insert.

| Column | Type | Description |
|---|---|---|
| `Exception_ID` | `VARCHAR(10)` | Exception number, for example `EXC-002` |
| `Account_ID` | `INT` | Customer account number |
| `Exception_Status` | `VARCHAR(30)` | `Resolved` or `Under Investigation` |
| `Approval_Reference` | `VARCHAR(30)` | Approval ID; `NULL` means no documented approval |

Sample data: 4 rows. EXC-002 (account 1005) is Resolved with a `NULL` approval, so it fails C-001.

### `#Remediation_Tracking_Lab04`
Remediation case opened for a failed control. One row per case.

| Column | Type | Description |
|---|---|---|
| `Remediation_ID` | `VARCHAR(10)` | Primary key, for example `REM-001` |
| `Exception_ID` | `VARCHAR(10)` | Exception that failed the control |
| `Account_ID` | `INT` | Customer account number |
| `Control_ID` | `VARCHAR(10)` | Control that failed, for example `C-001` |
| `Remediation_Status` | `VARCHAR(30)` | `Open` → `Under Investigation` → `Pending Management Review` → `Corrective Action Approved` → `Closed` |
| `Assigned_Owner` | `VARCHAR(100)` | Role responsible for the fix (simulated) |
| `Investigation_Finding` | `VARCHAR(300)` | What the investigation found |
| `Recommended_Action` | `VARCHAR(200)` | Current recommended action |
| `Investigation_Next_Step` | `VARCHAR(300)` | Next planned investigation activity |

### `#Remediation_Verification_Lab04`
Verification gates that must both pass before a remediation case can close.

| Column | Type | Description |
|---|---|---|
| `Remediation_ID` | `VARCHAR(10)` | Primary key; links to `#Remediation_Tracking_Lab04` |
| `Corrective_Control_Verified` | `BIT` | 1 = corrective control confirmed implemented, 0 = not verified |
| `Effectiveness_Test_Verified` | `BIT` | 1 = control independently confirmed to work, 0 = not verified |

**Calculated columns (not stored):** `Control_Result` (Pass / Fail / Not Applicable), `Remediation_Priority` (High / Low / Pending), `Pass_Rate_Percent`, `Closure_Readiness`, `Original_Control_Assessment` and `Approval_Display` are produced in queries.

## Labs 05–07

Tables will be added here as each lab is written.
