
-- =====================================================
-- BALBOA BAY PARTNERS
-- SQL LAB 03: MIGRATION EXCEPTION REPORT
-- =====================================================
-- OBJECTIVE:
-- Detect account status discrepancies, classify findings,
-- document investigations, simulate approval and closure,
-- and validate the final exception record.
--
-- DATA: Fictional utility customer accounts
-- PURPOSE: SQL learning and portfolio development
--
-- NOTE:
-- All approvals and evidence are simulated.
-- Temporary tables are used throughout this lab.
-- =====================================================


-- =====================================================
-- STEP 1: CREATE THE LEGACY ACCOUNT TABLE
-- =====================================================
-- Reset temporary tables for a clean execution.
-- Expected: 4 legacy records inserted.

DROP TABLE IF EXISTS #Migration_Exceptions;
DROP TABLE IF EXISTS #Target_Accounts_Lab03;
DROP TABLE IF EXISTS #Legacy_Accounts_Lab03;

CREATE TABLE #Legacy_Accounts_Lab03 (
    Account_ID INT,
    Account_Status VARCHAR(20)
);

INSERT INTO #Legacy_Accounts_Lab03
    (Account_ID, Account_Status)
VALUES
    (1001, 'Active'),
    (1002, 'Active'),
    (1003, 'Inactive'),
    (1004, 'Active');


-- STEP 2: INSPECT LEGACY RECORDS
-- Expected: 4 rows.

SELECT *
FROM #Legacy_Accounts_Lab03;


-- =====================================================
-- STEP 3: CREATE THE TARGET ACCOUNT TABLE
-- =====================================================
-- Expected: 4 target records inserted.

CREATE TABLE #Target_Accounts_Lab03 (
    Account_ID INT,
    Account_Status VARCHAR(20)
);

INSERT INTO #Target_Accounts_Lab03
    (Account_ID, Account_Status)
VALUES
    (1001, 'Active'),
    (1002, 'Inactive'),
    (1003, 'Inactive'),
    (1004, 'Active');


-- STEP 4: INSPECT TARGET RECORDS
-- Expected: 4 rows.

SELECT *
FROM #Target_Accounts_Lab03;


-- =====================================================
-- STEP 5: CLASSIFY ACCOUNT STATUS DISCREPANCIES
-- =====================================================
-- CASE WHEN creates a classification column.
-- Expected: 4 rows, 3 matches and 1 mismatch.

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,
    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Status Mismatch'
        ELSE 'Status Match'
    END AS Discrepancy_Type
FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID;


-- =====================================================
-- STEP 6: DISPLAY ONLY STATUS DISCREPANCIES
-- =====================================================
-- WHERE filters the results.
-- Expected: 1 row (Account 1002).

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,
    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Status Mismatch'
        ELSE 'Status Match'
    END AS Discrepancy_Type
FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
WHERE L.Account_Status <> T.Account_Status;


-- =====================================================
-- STEP 7: ADD A RECOMMENDED INVESTIGATION ACTION
-- =====================================================
-- CASE WHEN creates a Recommended_Action column.
-- Expected: 1 row (Account 1002).

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Status Mismatch'
        ELSE 'Status Match'
    END AS Discrepancy_Type,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Review deactivation history and migration log'
        ELSE 'No discrepancy detected'
    END AS Recommended_Action

FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
WHERE L.Account_Status <> T.Account_Status;


-- =====================================================
-- STEP 8: ADD EXPECTED TARGET STATUS
-- =====================================================
-- Expected values follow fictional mapping rules.
--
-- ASSUMPTIONS:
-- Active maps to Active.
-- Inactive maps to Inactive.
-- No authorized status changes were known at detection.
--
-- Expected: Account 1002 has Expected_Target_Status
-- of Active while actual Target_Status is Inactive.

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Status Mismatch'
        ELSE 'Status Match'
    END AS Discrepancy_Type,

    CASE
        WHEN L.Account_Status = 'Active'
            THEN 'Active'
        WHEN L.Account_Status = 'Inactive'
            THEN 'Inactive'
        ELSE 'Mapping Review Required'
    END AS Expected_Target_Status,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Review deactivation history and migration log'
        ELSE 'No discrepancy detected'
    END AS Recommended_Action

FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
WHERE L.Account_Status <> T.Account_Status;


-- =====================================================
-- STEP 9: ADD EXCEPTION STATUS CLASSIFICATION
-- =====================================================
-- A newly detected discrepancy starts as Open.
-- This is a calculated reporting column.
--
-- Expected: Account 1002, Exception_Status = Open.

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Status Mismatch'
        ELSE 'Status Match'
    END AS Discrepancy_Type,

    CASE
        WHEN L.Account_Status = 'Active'
            THEN 'Active'
        WHEN L.Account_Status = 'Inactive'
            THEN 'Inactive'
        ELSE 'Mapping Review Required'
    END AS Expected_Target_Status,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Review deactivation history and migration log'
        ELSE 'No discrepancy detected'
    END AS Recommended_Action,

    CASE
        WHEN L.Account_Status <> T.Account_Status
            THEN 'Open'
        ELSE 'No Exception'
    END AS Exception_Status

FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
WHERE L.Account_Status <> T.Account_Status;


-- =====================================================
-- STEP 10A: CREATE THE EXCEPTION TRACKING TABLE
-- =====================================================
-- Store investigation records separately from
-- customer account data.
-- Expected: Table created successfully.

CREATE TABLE #Migration_Exceptions (
    Exception_ID VARCHAR(10) PRIMARY KEY,
    Account_ID INT,
    Discrepancy_Type VARCHAR(50),
    Exception_Status VARCHAR(30),
    Recommended_Action VARCHAR(150),
    Evidence_Reference VARCHAR(100)
);


-- STEP 10B: INSERT THE FIRST EXCEPTION
-- Expected: 1 row inserted.

INSERT INTO #Migration_Exceptions (
    Exception_ID,
    Account_ID,
    Discrepancy_Type,
    Exception_Status,
    Recommended_Action,
    Evidence_Reference
)
VALUES (
    'EXC-001',
    1002,
    'Status Mismatch',
    'Open',
    'Review deactivation history and migration log',
    NULL
);


-- STEP 10C: VERIFY THE EXCEPTION RECORD
-- Expected: EXC-001, Open, NULL evidence.

SELECT
    Exception_ID,
    Account_ID,
    Discrepancy_Type,
    Exception_Status,
    Recommended_Action,
    Evidence_Reference
FROM #Migration_Exceptions;


-- =====================================================
-- STEP 11: BEGIN THE EXCEPTION INVESTIGATION
-- =====================================================
-- Update investigation progress only.
-- Customer account data remains unchanged.
-- Expected: 1 row affected.

UPDATE #Migration_Exceptions
SET Exception_Status = 'Under Investigation'
WHERE Exception_ID = 'EXC-001'
  AND Exception_Status = 'Open';


-- STEP 11B: VERIFY THE INVESTIGATION STATUS
-- Expected: Under Investigation.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Evidence_Reference
FROM #Migration_Exceptions;


-- =====================================================
-- STEP 12: RECORD AN EVIDENCE REFERENCE
-- =====================================================
-- Evidence identifier is fictional.
-- Recording a reference does not validate the evidence.
-- Expected: 1 row affected.

UPDATE #Migration_Exceptions
SET Evidence_Reference = 'STATUS-HISTORY-1002'
WHERE Exception_ID = 'EXC-001'
  AND Exception_Status = 'Under Investigation';


-- STEP 12B: VERIFY EVIDENCE REFERENCE
-- Expected: STATUS-HISTORY-1002.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Evidence_Reference
FROM #Migration_Exceptions
WHERE Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 13A: ADD INVESTIGATION FINDINGS COLUMN
-- =====================================================
-- ALTER TABLE changes the table structure.
-- Expected: 1 new column added.

ALTER TABLE #Migration_Exceptions
ADD Investigation_Findings VARCHAR(500);

GO


-- STEP 13B: RECORD SIMULATED FINDINGS
-- Expected: 1 row affected.
-- Initial finding does not establish root cause.

UPDATE #Migration_Exceptions
SET Investigation_Findings =
    'Simulated initial finding: Migration process set target status to Inactive. ' +
    'Root cause and authorization not yet confirmed. ' +
    'Additional evidence required.'
WHERE Exception_ID = 'EXC-001'
  AND Exception_Status = 'Under Investigation';


-- STEP 13C: VERIFY INVESTIGATION FINDINGS

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Evidence_Reference,
    Investigation_Findings
FROM #Migration_Exceptions
WHERE Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 14A: ADD RESOLUTION DOCUMENTATION FIELDS
-- =====================================================
-- Preserve investigation findings separately.
-- Expected: 3 new columns added.

ALTER TABLE #Migration_Exceptions
ADD
    Resolution_Decision VARCHAR(200),
    Resolution_Reason VARCHAR(500),
    Resolution_Status VARCHAR(30);

GO


-- STEP 14B: DOCUMENT SIMULATED RESOLUTION
-- Expected: 1 row affected.
-- This is a fictional scenario, not actual approval.

UPDATE #Migration_Exceptions
SET
    Resolution_Decision = 'No account correction required',
    Resolution_Reason =
        'Simulated investigation confirmed an authorized cancellation after the migration snapshot. ' +
        'Target status Inactive is consistent with assumed approved migration rules.',
    Resolution_Status = 'Pending Approval'
WHERE Exception_ID = 'EXC-001'
  AND Exception_Status = 'Under Investigation';


-- STEP 14C: VERIFY RESOLUTION DOCUMENTATION
-- Expected: Pending Approval.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Investigation_Findings,
    Resolution_Decision,
    Resolution_Reason,
    Resolution_Status
FROM #Migration_Exceptions
WHERE Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 15A: ADD APPROVAL TRACKING FIELDS
-- =====================================================
-- Expected: 2 new columns added.

ALTER TABLE #Migration_Exceptions
ADD
    Approved_By VARCHAR(100),
    Approval_Reference VARCHAR(100);

GO


-- STEP 15B: RECORD SIMULATED APPROVAL
-- Expected: 1 row affected.

UPDATE #Migration_Exceptions
SET
    Approved_By = 'Billing Manager (Simulated)',
    Approval_Reference = 'APP-EXC-001',
    Resolution_Status = 'Approved'
WHERE Exception_ID = 'EXC-001'
  AND Resolution_Status = 'Pending Approval';


-- STEP 15C: VERIFY SIMULATED APPROVAL
-- Expected: Resolution_Status = Approved.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Resolution_Status,
    Approved_By,
    Approval_Reference
FROM #Migration_Exceptions
WHERE Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 16A: CLOSE THE APPROVED EXCEPTION
-- =====================================================
-- Apply closure only when required fields are populated.
-- Expected: 1 row affected.
-- Customer account data remains unchanged.

UPDATE #Migration_Exceptions
SET Exception_Status = 'Resolved'
WHERE Exception_ID = 'EXC-001'
  AND Resolution_Status = 'Approved'
  AND Exception_Status = 'Under Investigation'
  AND Approved_By IS NOT NULL
  AND Approval_Reference IS NOT NULL;


-- STEP 16B: VERIFY EXCEPTION CLOSURE
-- Expected: Resolved and Approved.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Resolution_Decision,
    Resolution_Status,
    Approved_By,
    Approval_Reference,
    Evidence_Reference
FROM #Migration_Exceptions
WHERE Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 17A: VERIFY CUSTOMER STATUS IS UNCHANGED
-- =====================================================
-- Expected: Target_Status = Inactive.
-- Exception_Status = Resolved.

SELECT
    T.Account_ID,
    T.Account_Status AS Target_Status,
    E.Exception_ID,
    E.Exception_Status,
    E.Resolution_Status
FROM #Target_Accounts_Lab03 AS T
INNER JOIN #Migration_Exceptions AS E
    ON T.Account_ID = E.Account_ID
WHERE T.Account_ID = 1002;


-- STEP 17B: COMPARE LEGACY AND TARGET STATUSES
-- Expected: Legacy Active, Target Inactive.
-- Resolution: No account correction required.

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,
    E.Exception_ID,
    E.Exception_Status,
    E.Resolution_Decision
FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
INNER JOIN #Migration_Exceptions AS E
    ON L.Account_ID = E.Account_ID
WHERE L.Account_ID = 1002;


-- =====================================================
-- STEP 18A: FINAL EXCEPTION VALIDATION
-- =====================================================
-- Consolidate customer status, exception details,
-- investigation findings, and approval references.
--
-- Expected: 1 row (Account 1002, EXC-001).

SELECT
    L.Account_ID,
    L.Account_Status AS Legacy_Status,
    T.Account_Status AS Target_Status,
    E.Exception_ID,
    E.Discrepancy_Type,
    E.Exception_Status,
    E.Resolution_Decision,
    E.Resolution_Status,
    E.Evidence_Reference,
    E.Approved_By,
    E.Approval_Reference,
    E.Investigation_Findings

FROM #Legacy_Accounts_Lab03 AS L
INNER JOIN #Target_Accounts_Lab03 AS T
    ON L.Account_ID = T.Account_ID
INNER JOIN #Migration_Exceptions AS E
    ON L.Account_ID = E.Account_ID

WHERE E.Exception_ID = 'EXC-001';


-- =====================================================
-- STEP 18B: FINAL VALIDATION SUMMARY
-- =====================================================
--
-- DATASET SUMMARY
-- Legacy accounts:                 4
-- Target accounts:                 4
-- Status mismatches detected:      1
--
-- EXCEPTION SUMMARY
-- Exception_ID:                    EXC-001
-- Account_ID:                      1002
-- Legacy_Status:                   Active
-- Target_Status:                   Inactive
-- Discrepancy_Type:                Status Mismatch
--
-- INVESTIGATION OUTCOME
-- Exception_Status:                Resolved
-- Resolution_Status:               Approved
-- Resolution_Decision:             No account correction required
-- Evidence_Reference:              STATUS-HISTORY-1002
-- Approval_Reference:              APP-EXC-001
--
-- VALIDATION
-- Customer target status remains Inactive.
-- Simulated resolution and approval recorded.
-- Initial investigation findings retained.
-- No customer account correction performed.
--
-- LIMITATIONS
-- All data, evidence, and approvals are fictional.
-- Evidence identifiers do not represent actual files.
-- Historical events were not independently verified.
-- No immutable audit-event history was implemented.
-- This lab demonstrates the workflow, not a
-- production-ready approval or control system.
--
-- END OF SQL LAB 03
-- =====================================================
