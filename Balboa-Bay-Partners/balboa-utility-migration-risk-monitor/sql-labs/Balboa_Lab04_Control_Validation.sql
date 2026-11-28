-- =====================================================
-- BALBOA BAY PARTNERS | SQL LAB 04
-- MIGRATION RISK & CONTROL VALIDATION
-- =====================================================
-- PURPOSE:
--   Test control C-001, investigate an exception, track
--   remediation, apply verification gates, and report
--   the original approval gap alongside remediation closure. 
--
-- CONTROL C-001:
--   Every resolved migration exception must have a
--   documented approval reference.
--
-- DATA AND ASSUMPTIONS:
--   Fictional accounts and simulated management actions.
--   An approval reference is not proof of valid approval.
--   Verification BIT flags model reviewer decisions, not
--   independently authenticated evidence.
--   Closure does not erase a historical control failure.
--
-- HOW TO RUN:
--   Execute the complete script in SQL Server Management
--   Studio (SSMS), in one query window, from top to bottom.
--   The initial DROP statements reset all lab tables.
--   All tables are temporary and session-scoped.
--
-- EXPECTED FINAL OUTCOME:
--   EXC-002 / Account 1005: historical approval NULL
--   REM-001: Closed, both verification flags = 1
--   Final approval display: Not Documented
-- =====================================================

-- =====================================================
-- STEP 1: CREATE THE CONTROL TESTING DATASET
-- =====================================================
-- Control C-001:
-- Every resolved migration exception must have
-- documented approval.
--
-- Expected: 4 exception records.

-- Reset temporary tables for a clean, repeatable run.
DROP TABLE IF EXISTS #Remediation_Verification_Lab04;
DROP TABLE IF EXISTS #Remediation_Tracking_Lab04;
DROP TABLE IF EXISTS #Control_Testing_Lab04;

CREATE TABLE #Control_Testing_Lab04 (
    Exception_ID VARCHAR(10),
    Account_ID INT,
    Exception_Status VARCHAR(30),
    Approval_Reference VARCHAR(30)
);

INSERT INTO #Control_Testing_Lab04
    (Exception_ID, Account_ID, Exception_Status, Approval_Reference)
VALUES
    ('EXC-001', 1002, 'Resolved', 'APP-001'),
    ('EXC-002', 1005, 'Resolved', NULL),
    ('EXC-003', 1007, 'Under Investigation', NULL),
    ('EXC-004', 1010, 'Resolved', 'APP-004');

-- =====================================================
-- STEP 2: INSPECT THE CONTROL TESTING DATASET
-- =====================================================
-- Expected: 4 rows.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference
FROM #Control_Testing_Lab04;


-- =====================================================
-- STEP 3: IDENTIFY CONTROL C-001 FAILURES
-- =====================================================
-- Expected: 1 row, EXC-002 (Account 1005)
-- Resolved exceptions must have approval references.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference
FROM #Control_Testing_Lab04
WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 4: CLASSIFY CONTROL C-001 RESULTS
-- =====================================================
-- Expected:
-- 2 Pass
-- 1 Fail
-- 1 Not Applicable

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'Fail'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Pass'

        ELSE 'Not Applicable'
    END AS Control_Result

FROM #Control_Testing_Lab04;


-- =====================================================
-- STEP 5: SUMMARIZE CONTROL C-001 RESULTS
-- =====================================================
-- Expected: 2 Pass, 1 Fail, 1 Not Applicable

SELECT
    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'Fail'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Pass'

        ELSE 'Not Applicable'
    END AS Control_Result,

    COUNT(*) AS Total_Exceptions

FROM #Control_Testing_Lab04

GROUP BY
    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'Fail'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Pass'

        ELSE 'Not Applicable'
    END;


-- =====================================================
-- STEP 6: CALCULATE CONTROL C-001 PASS RATE
-- =====================================================
-- Expected: 3 applicable exceptions
-- 2 Pass, 1 Fail, 66.67% pass rate

SELECT
    COUNT(*) AS Applicable_Exceptions,

    SUM(
        CASE
            WHEN Approval_Reference IS NOT NULL
                THEN 1
            ELSE 0
        END
    ) AS Passed_Exceptions,

    SUM(
        CASE
            WHEN Approval_Reference IS NULL
                THEN 1
            ELSE 0
        END
    ) AS Failed_Exceptions,

    CAST(
        100.0 * SUM(
            CASE
                WHEN Approval_Reference IS NOT NULL
                    THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Pass_Rate_Percent

FROM #Control_Testing_Lab04
WHERE Exception_Status = 'Resolved';


-- =====================================================
-- STEP 7: IDENTIFY FAILED CONTROL RECORDS
-- =====================================================
-- Control C-001: Resolved exceptions require approval.
-- Expected: 1 row, EXC-002 (Account 1005)

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,
    'Missing Approval Reference' AS Control_Failure_Reason
FROM #Control_Testing_Lab04
WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 8: RECOMMEND CORRECTIVE ACTION
-- =====================================================
-- Expected: 1 row, EXC-002 (Account 1005)
-- Purpose: Identify the failed control and next action.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    'Missing Approval Reference' AS Control_Failure_Reason,

    'Verify approval history and escalate if approval is absent'
        AS Recommended_Action

FROM #Control_Testing_Lab04

WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 9: ASSIGN CONTROL REMEDIATION PRIORITY
-- =====================================================
-- Expected: 4 rows
-- 1 High, 2 Low, 1 Pending

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'High'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Low'

        ELSE 'Pending'
    END AS Remediation_Priority

FROM #Control_Testing_Lab04;


-- =====================================================
-- STEP 10: SUMMARIZE REMEDIATION PRIORITIES
-- =====================================================
-- Expected:
-- High: 1
-- Low: 2
-- Pending: 1

SELECT
    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'High'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Low'

        ELSE 'Pending'
    END AS Remediation_Priority,

    COUNT(*) AS Total_Exceptions

FROM #Control_Testing_Lab04

GROUP BY
    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'High'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Low'

        ELSE 'Pending'
    END;


-- =====================================================
-- STEP 11: IDENTIFY HIGH-PRIORITY REMEDIATION
-- =====================================================
-- Expected: 1 row, EXC-002 (Account 1005)

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    CASE
        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NULL
            THEN 'High'

        WHEN Exception_Status = 'Resolved'
             AND Approval_Reference IS NOT NULL
            THEN 'Low'

        ELSE 'Pending'
    END AS Remediation_Priority

FROM #Control_Testing_Lab04

WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 12: ASSIGN REMEDIATION OWNERSHIP
-- =====================================================
-- Expected: 1 row, EXC-002 (Account 1005)

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    'High' AS Remediation_Priority,
    'Billing Operations Manager' AS Proposed_Owner,
    'Verify approval history and document findings'
        AS Recommended_Action

FROM #Control_Testing_Lab04

WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 13: DOCUMENT CONTROL INVESTIGATION FINDINGS
-- =====================================================
-- Expected: 1 row, EXC-002 (Account 1005)
-- Purpose: Report the simulated investigation outcome.
-- No underlying data is modified.

SELECT
    Exception_ID,
    Account_ID,
    Exception_Status,
    Approval_Reference,

    'High' AS Remediation_Priority,

    'Billing Operations Manager' AS Proposed_Owner,

    'Simulated review found no documented approval'
        AS Investigation_Finding,

    'Escalate closure for management review'
        AS Recommended_Action

FROM #Control_Testing_Lab04

WHERE Exception_Status = 'Resolved'
  AND Approval_Reference IS NULL;


-- =====================================================
-- STEP 14A: CREATE REMEDIATION TRACKING TABLE
-- =====================================================
-- Expected: Table created successfully

CREATE TABLE #Remediation_Tracking_Lab04 (
    Remediation_ID VARCHAR(10) PRIMARY KEY,
    Exception_ID VARCHAR(10),
    Account_ID INT,
    Control_ID VARCHAR(10),
    Remediation_Status VARCHAR(30),
    Assigned_Owner VARCHAR(100),
    Investigation_Finding VARCHAR(300),
    Recommended_Action VARCHAR(200),
    Investigation_Next_Step VARCHAR(300)
);


-- =====================================================
-- STEP 14B: RECORD THE REMEDIATION CASE
-- =====================================================
-- Expected: 1 row inserted

INSERT INTO #Remediation_Tracking_Lab04 (
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
)
VALUES (
    'REM-001',
    'EXC-002',
    1005,
    'C-001',
    'Open',
    'Billing Operations Manager (Simulated)',
    'Simulated review found no documented approval',
    'Escalate closure for management review'
);


-- =====================================================
-- STEP 14C: VERIFY REMEDIATION TRACKING RECORD
-- =====================================================
-- Expected: 1 row, REM-001

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
FROM #Remediation_Tracking_Lab04;


-- =====================================================
-- STEP 15A: BEGIN REMEDIATION INVESTIGATION
-- =====================================================
-- Purpose: Update the remediation workflow status.
-- Expected: 1 row affected.
-- Original exception and control data remain unchanged.

UPDATE #Remediation_Tracking_Lab04
SET Remediation_Status = 'Under Investigation'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Open';


-- =====================================================
-- STEP 15B: VERIFY REMEDIATION INVESTIGATION STATUS
-- =====================================================
-- Expected: REM-001, Under Investigation.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 16A: INVESTIGATION NEXT STEP FIELD
-- =====================================================
-- Investigation_Next_Step was created in Step 14A.
-- No ALTER TABLE statement is required.


-- =====================================================
-- STEP 16B: DOCUMENT THE NEXT INVESTIGATION ACTIVITY
-- =====================================================
-- Expected: 1 row affected.

UPDATE #Remediation_Tracking_Lab04
SET Investigation_Next_Step =
    'Contact Billing Operations Manager to verify original approval, ' +
    'review closure history, and identify missing documentation.'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Under Investigation';


-- =====================================================
-- STEP 16C: VERIFY THE INVESTIGATION PLAN
-- =====================================================
-- Expected: 1 row, REM-001.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Investigation_Next_Step
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 17A: UPDATE INVESTIGATION FINDINGS
-- =====================================================
-- Scenario:
-- Simulated management review found no original
-- approval documentation.
--
-- Expected: 1 row affected.
-- Remediation remains Under Investigation.

UPDATE #Remediation_Tracking_Lab04
SET Investigation_Finding =
    'Simulated management review could not locate ' +
    'original approval documentation. ' +
    'Approval remains unverified.'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Under Investigation';


-- =====================================================
-- STEP 17B: VERIFY UPDATED FINDINGS
-- =====================================================
-- Expected: 1 row, REM-001.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Investigation_Next_Step
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';

-- =====================================================
-- STEP 18A: REFINE THE INVESTIGATION NEXT STEP
-- =====================================================
-- Expected: 1 row affected.
-- Purpose: Escalate the unresolved evidence gap.

UPDATE #Remediation_Tracking_Lab04
SET Investigation_Next_Step =
    'Escalate the missing approval evidence to the ' +
    'control owner for an authorization review and ' +
    'document the management decision.'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Under Investigation';


-- =====================================================
-- STEP 18B: VERIFY UPDATED INVESTIGATION PLAN
-- =====================================================
-- Expected: 1 row.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Investigation_Finding,
    Investigation_Next_Step
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 19A: DOCUMENT MANAGEMENT REVIEW OUTCOME
-- =====================================================
-- Scenario: Simulated management review determines
-- original approval cannot be verified.
--
-- Expected: 1 row affected.
-- Remediation remains Under Investigation.

UPDATE #Remediation_Tracking_Lab04
SET Recommended_Action =
    'Keep remediation open; obtain formal corrective ' +
    'action approval and document the control failure.'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Under Investigation';


-- =====================================================
-- STEP 19B: VERIFY MANAGEMENT REVIEW OUTCOME
-- =====================================================
-- Expected: 1 row, REM-001.

SELECT
    Remediation_ID,
    Exception_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 20A: UPDATE REMEDIATION WORKFLOW STATUS
-- =====================================================
-- Purpose: Move remediation into management review.
-- Expected: 1 row affected.
-- The original control failure remains unresolved.

UPDATE #Remediation_Tracking_Lab04
SET Remediation_Status = 'Pending Management Review'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Under Investigation';


-- =====================================================
-- STEP 20B: VERIFY MANAGEMENT REVIEW STATUS
-- =====================================================
-- Expected: 1 row, REM-001.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 21A: RECORD SIMULATED MANAGEMENT DECISION
-- =====================================================
-- Purpose:
-- Simulate management authorization of a corrective
-- action plan without closing the remediation.
--
-- Expected: 1 row affected.

UPDATE #Remediation_Tracking_Lab04
SET
    Remediation_Status = 'Corrective Action Approved',
    Recommended_Action =
        'Document historical control failure, ' +
        'implement corrective controls, and verify ' +
        'effectiveness before remediation closure.'
WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Pending Management Review';


-- =====================================================
-- STEP 21B: VERIFY MANAGEMENT DECISION
-- =====================================================
-- Expected: 1 row, REM-001.

SELECT
    Remediation_ID,
    Exception_ID,
    Account_ID,
    Control_ID,
    Remediation_Status,
    Assigned_Owner,
    Investigation_Finding,
    Recommended_Action
FROM #Remediation_Tracking_Lab04
WHERE Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 22: DEFINE REMEDIATION CLOSURE REQUIREMENTS
-- =====================================================
-- Expected: 1 row, REM-001.
-- Purpose: Document what must be verified before closure.
-- This SELECT does not change stored data.

SELECT
    Remediation_ID,
    Exception_ID,
    Control_ID,
    Remediation_Status,

    'Historical control failure documented'
        AS Requirement_1,

    'Corrective control implemented'
        AS Requirement_2,

    'Control effectiveness independently verified'
        AS Requirement_3,

    'Not Yet Verified'
        AS Closure_Readiness

FROM #Remediation_Tracking_Lab04

WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Corrective Action Approved';


-- =====================================================
-- STEP 23: IDENTIFY OUTSTANDING CLOSURE REQUIREMENTS
-- =====================================================
-- Purpose: Report remediation closure readiness.
-- Expected: 1 row, REM-001.
-- Reporting labels below are hard-coded training assumptions.
-- No database records are modified.

SELECT
    Remediation_ID,
    Exception_ID,
    Control_ID,
    Remediation_Status,

    'Documented in Simulated Investigation'
        AS Historical_Failure_Status,

    'Not Verified'
        AS Corrective_Control_Status,

    'Not Verified'
        AS Effectiveness_Test_Status,

    'Not Ready for Closure'
        AS Closure_Readiness

FROM #Remediation_Tracking_Lab04

WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Corrective Action Approved';

-- =====================================================
-- STEP 24: IDENTIFY REMEDIATION CLOSURE BLOCKERS
-- =====================================================
-- Purpose:
-- Report the outstanding verification requirements.
--
-- Expected: 1 row, REM-001.
-- No database records are modified.

SELECT
    Remediation_ID,
    Exception_ID,
    Control_ID,
    Remediation_Status,

    'Corrective control implementation not verified'
        AS Closure_Blocker_1,

    'Independent effectiveness testing not verified'
        AS Closure_Blocker_2,

    'Not Ready for Closure'
        AS Closure_Readiness

FROM #Remediation_Tracking_Lab04

WHERE Remediation_ID = 'REM-001'
  AND Remediation_Status = 'Corrective Action Approved';


-- =====================================================
-- STEP 25A: CREATE REMEDIATION VERIFICATION TABLE
-- =====================================================
-- Purpose: Store verification status for each requirement.
-- Expected: Table created successfully.

CREATE TABLE #Remediation_Verification_Lab04 (
    Remediation_ID VARCHAR(10) PRIMARY KEY,
    Corrective_Control_Verified BIT,
    Effectiveness_Test_Verified BIT
);


-- =====================================================
-- STEP 25B: RECORD CURRENT VERIFICATION RESULTS
-- =====================================================
-- BIT values:
-- 0 = Not Verified
-- 1 = Verified
--
-- Expected: 1 row inserted.

INSERT INTO #Remediation_Verification_Lab04 (
    Remediation_ID,
    Corrective_Control_Verified,
    Effectiveness_Test_Verified
)
VALUES (
    'REM-001',
    0,
    0
);


-- =====================================================
-- STEP 25C: CALCULATE CLOSURE READINESS
-- =====================================================
-- Expected: REM-001, Not Ready for Closure.
-- Both verification checks must equal 1.

SELECT
    R.Remediation_ID,
    R.Remediation_Status,
    V.Corrective_Control_Verified,
    V.Effectiveness_Test_Verified,

    CASE
        WHEN V.Corrective_Control_Verified = 1
             AND V.Effectiveness_Test_Verified = 1
            THEN 'Ready for Closure'
        ELSE 'Not Ready for Closure'
    END AS Closure_Readiness

FROM #Remediation_Tracking_Lab04 AS R
INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID

WHERE R.Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 26A: VERIFY CORRECTIVE CONTROL IMPLEMENTATION
-- =====================================================
-- Scenario: Authorized reviewer confirms implementation.
-- Simulated verification only.
--
-- Expected: 1 row affected.
-- Effectiveness test remains unverified.

UPDATE #Remediation_Verification_Lab04
SET Corrective_Control_Verified = 1
WHERE Remediation_ID = 'REM-001'
  AND Corrective_Control_Verified = 0;


-- =====================================================
-- STEP 26B: RECALCULATE CLOSURE READINESS
-- =====================================================
-- Expected:
-- Corrective_Control_Verified = 1
-- Effectiveness_Test_Verified = 0
-- Closure_Readiness = Not Ready for Closure

SELECT
    R.Remediation_ID,
    R.Remediation_Status,
    V.Corrective_Control_Verified,
    V.Effectiveness_Test_Verified,

    CASE
        WHEN V.Corrective_Control_Verified = 1
             AND V.Effectiveness_Test_Verified = 1
            THEN 'Ready for Closure'
        ELSE 'Not Ready for Closure'
    END AS Closure_Readiness

FROM #Remediation_Tracking_Lab04 AS R
INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID

WHERE R.Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 27A: VERIFY CONTROL EFFECTIVENESS
-- =====================================================
-- Scenario: Independent reviewer confirms the
-- corrective control operates as intended.
-- This is simulated verification.
--
-- Expected: 1 row affected.

UPDATE #Remediation_Verification_Lab04
SET Effectiveness_Test_Verified = 1
WHERE Remediation_ID = 'REM-001'
  AND Corrective_Control_Verified = 1
  AND Effectiveness_Test_Verified = 0;


-- =====================================================
-- STEP 27B: RECALCULATE CLOSURE READINESS
-- =====================================================
-- Expected:
-- Corrective_Control_Verified = 1
-- Effectiveness_Test_Verified = 1
-- Closure_Readiness = Ready for Closure

SELECT
    R.Remediation_ID,
    R.Remediation_Status,
    V.Corrective_Control_Verified,
    V.Effectiveness_Test_Verified,

    CASE
        WHEN V.Corrective_Control_Verified = 1
             AND V.Effectiveness_Test_Verified = 1
            THEN 'Ready for Closure'
        ELSE 'Not Ready for Closure'
    END AS Closure_Readiness

FROM #Remediation_Tracking_Lab04 AS R
INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID

WHERE R.Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 28A: CLOSE VERIFIED REMEDIATION
-- =====================================================
-- Purpose:
-- Close remediation only when both verification
-- requirements have passed.
--
-- Scenario: Simulated authorized closure.
-- Expected: 1 row affected.

UPDATE R
SET R.Remediation_Status = 'Closed'
FROM #Remediation_Tracking_Lab04 AS R
INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID
WHERE R.Remediation_ID = 'REM-001'
  AND R.Remediation_Status = 'Corrective Action Approved'
  AND V.Corrective_Control_Verified = 1
  AND V.Effectiveness_Test_Verified = 1;


-- =====================================================
-- STEP 28B: VERIFY REMEDIATION CLOSURE
-- =====================================================
-- Expected:
-- Remediation_Status = Closed
-- Both verification values = 1

SELECT
    R.Remediation_ID,
    R.Exception_ID,
    R.Control_ID,
    R.Remediation_Status,
    V.Corrective_Control_Verified,
    V.Effectiveness_Test_Verified

FROM #Remediation_Tracking_Lab04 AS R
INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID

WHERE R.Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 29: FINAL CONTROL AND REMEDIATION VALIDATION
-- =====================================================
-- Expected: 1 row, EXC-002 / REM-001.
-- Original approval reference remains NULL.
-- Remediation is Closed with both checks verified.

SELECT
    C.Exception_ID,
    C.Account_ID,
    C.Exception_Status,
    C.Approval_Reference,
    R.Control_ID,
    R.Remediation_ID,
    R.Remediation_Status,
    V.Corrective_Control_Verified,
    V.Effectiveness_Test_Verified,

    CASE
        WHEN C.Exception_Status = 'Resolved'
             AND C.Approval_Reference IS NULL
            THEN 'Historical Control Failure'
        ELSE 'No Historical Failure Detected'
    END AS Original_Control_Assessment

FROM #Control_Testing_Lab04 AS C

INNER JOIN #Remediation_Tracking_Lab04 AS R
    ON C.Exception_ID = R.Exception_ID
   AND C.Account_ID = R.Account_ID

INNER JOIN #Remediation_Verification_Lab04 AS V
    ON R.Remediation_ID = V.Remediation_ID

WHERE R.Remediation_ID = 'REM-001';


-- =====================================================
-- STEP 30: DISPLAY ORIGINAL APPROVAL AND REMEDIATION
-- =====================================================
-- Purpose:
-- Preserve the original approval value while
-- providing descriptive information and traceability.
--
-- Expected: 1 row, EXC-002 (Account 1005).
-- Original approval remains NULL.

SELECT
    C.Exception_ID,
    C.Account_ID,

    C.Approval_Reference AS Original_Approval_Reference,

    CASE
        WHEN C.Approval_Reference IS NULL
            THEN 'Not Documented'
        ELSE C.Approval_Reference
    END AS Approval_Display,

    R.Remediation_ID AS Remediation_Reference,
    R.Remediation_Status

FROM #Control_Testing_Lab04 AS C

INNER JOIN #Remediation_Tracking_Lab04 AS R
    ON C.Exception_ID = R.Exception_ID
   AND C.Account_ID = R.Account_ID

WHERE C.Exception_ID = 'EXC-002';

-- =====================================================
-- FINAL LAB SUMMARY
-- =====================================================
-- Step 1-6:   Create records and measure control C-001.
-- Step 7-13:  Explain the failure and propose investigation.
-- Step 14-21: Track remediation, investigation, and review.
-- Step 22-24: Describe closure requirements and blockers.
-- Step 25-28: Store verification flags and enforce closure.
-- Step 29-30: Validate history and display remediation link.
--
-- EXPECTED FINAL RESULTS:
--   Applicable: 3 | Pass: 2 | Fail: 1 | Rate: 66.67%
--   Historical failure: EXC-002 / Account 1005
--   Original approval: NULL (unchanged)
--   Remediation reference: REM-001
--   Remediation status: Closed
--   Corrective control verified: 1 (simulated)
--   Effectiveness test verified: 1 (simulated)
--
-- LIMITATIONS:
--   Workflow events are updated in place; this is not an
--   immutable audit trail. Approval and verification are
--   simulated. Step 22-24 labels are hard-coded examples;
--   Steps 25-29 use stored verification values.
-- =====================================================
