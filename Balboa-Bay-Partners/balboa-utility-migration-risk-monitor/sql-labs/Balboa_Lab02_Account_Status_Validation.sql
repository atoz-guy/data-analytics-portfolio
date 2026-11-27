
-- =====================================================
-- BALBOA BAY PARTNERS
-- SQL LAB 02: ACCOUNT STATUS VALIDATION
-- =====================================================
-- OBJECTIVE:
-- Inspect source data, identify status discrepancies,
-- create a corrected working copy, apply simulated
-- transformations, and validate the results.
--
-- DATA: Fictional utility customer accounts
-- =====================================================


-- STEP 1: Reset the original temporary table
-- Allows us to rerun the lab without table conflicts.

DROP TABLE IF EXISTS #Legacy_Status;


-- STEP 2: Create the original legacy table
-- INT stores whole-number account IDs.
-- VARCHAR(20) stores variable-length status text.

CREATE TABLE #Legacy_Status (
    Account_ID INT,
    Account_Status VARCHAR(20)
);


-- STEP 3: Insert six fictional customer records
-- Some values intentionally contain data quality issues.

INSERT INTO #Legacy_Status (Account_ID, Account_Status)
VALUES
    (1001, 'Active'),
    (1002, 'A'),
    (1003, 'Inactive'),
    (1004, 'Actve'),
    (1005, 'Active '),
    (1006, 'Suspended');


-- STEP 4: Inspect all original account records
-- Displays the data before transformation.

SELECT *
FROM #Legacy_Status;


-- STEP 5: Identify distinct account statuses
-- DISTINCT removes duplicate values from the results.
-- SQL Server generally ignores trailing spaces
-- when comparing VARCHAR values.

SELECT DISTINCT Account_Status
FROM #Legacy_Status;


-- STEP 6: Detect potential trailing-space issues
-- LEN() excludes trailing spaces.
-- DATALENGTH() measures stored bytes.
-- This comparison is suitable for our VARCHAR sample.

SELECT
    Account_ID,
    Account_Status,
    LEN(Account_Status) AS Character_Length,
    DATALENGTH(Account_Status) AS Storage_Bytes
FROM #Legacy_Status
WHERE DATALENGTH(Account_Status) > LEN(Account_Status);


-- STEP 7: Identify unapproved account statuses
-- Fictional approved values:
-- Active, Inactive, Suspended.
-- NOT IN identifies values outside that list.

SELECT
    Account_ID,
    Account_Status
FROM #Legacy_Status
WHERE Account_Status NOT IN (
    'Active',
    'Inactive',
    'Suspended'
);


-- STEP 8: Reset the corrected temporary table
-- This does not change the original source table.

DROP TABLE IF EXISTS #Legacy_Status_Corrected;


-- STEP 9: Create a corrected working copy
-- SELECT INTO creates a separate table and copies
-- all records from the original dataset.

SELECT *
INTO #Legacy_Status_Corrected
FROM #Legacy_Status;


-- STEP 10: Inspect the copied data
-- Verify that all six original records were copied.

SELECT *
FROM #Legacy_Status_Corrected;


-- STEP 11: Correct account 1004
-- Simulated approved spelling correction:
-- Actve -> Active.
-- WHERE limits the update to the intended record
-- and its original status.

UPDATE #Legacy_Status_Corrected
SET Account_Status = 'Active'
WHERE Account_ID = 1004
  AND Account_Status = 'Actve';


-- STEP 12: Identify differences after correction
-- INNER JOIN matches accounts by Account_ID.
-- OR detects text differences or byte-length changes.
-- Expected: 1 row (1004), since only 1004
-- has been corrected at this point.

SELECT
    O.Account_ID,
    O.Account_Status AS Original_Status,
    C.Account_Status AS Corrected_Status
FROM #Legacy_Status AS O
INNER JOIN #Legacy_Status_Corrected AS C
    ON O.Account_ID = C.Account_ID
WHERE O.Account_Status <> C.Account_Status
   OR DATALENGTH(O.Account_Status) <> DATALENGTH(C.Account_Status);


-- STEP 13: Display all original and corrected statuses
-- Removing WHERE shows every matching account,
-- regardless of whether its status changed.

SELECT
    O.Account_ID,
    O.Account_Status AS Original_Status,
    C.Account_Status AS Corrected_Status
FROM #Legacy_Status AS O
INNER JOIN #Legacy_Status_Corrected AS C
    ON O.Account_ID = C.Account_ID;


-- STEP 14: Investigate account 1005
-- Compare character length and storage bytes
-- before removing the trailing space.

SELECT
    Account_ID,
    Account_Status,
    LEN(Account_Status) AS Character_Length,
    DATALENGTH(Account_Status) AS Storage_Bytes
FROM #Legacy_Status_Corrected
WHERE Account_ID = 1005;


-- STEP 15: Preview TRIM() without modifying data
-- TRIM() removes leading and trailing spaces.
-- SELECT demonstrates the expected transformation.

SELECT
    Account_ID,
    Account_Status AS Current_Status,
    TRIM(Account_Status) AS Trimmed_Status,
    DATALENGTH(Account_Status) AS Original_Bytes,
    DATALENGTH(TRIM(Account_Status)) AS Trimmed_Bytes
FROM #Legacy_Status_Corrected
WHERE Account_ID = 1005;


-- STEP 16: Apply the trimming correction
-- UPDATE modifies only the corrected working copy.

UPDATE #Legacy_Status_Corrected
SET Account_Status = TRIM(Account_Status)
WHERE Account_ID = 1005;


-- STEP 17: Verify account 1005 after TRIM()
-- Expected result: 6 characters and 6 bytes.

SELECT
    Account_ID,
    LEN(Account_Status) AS Character_Length,
    DATALENGTH(Account_Status) AS Storage_Bytes
FROM #Legacy_Status_Corrected
WHERE Account_ID = 1005;


-- STEP 18: Apply the approved abbreviation mapping
-- Assumption: 'A' means 'Active' in the legacy system.
-- In a real migration, confirm with the client first.

UPDATE #Legacy_Status_Corrected
SET Account_Status = 'Active'
WHERE Account_ID = 1002
  AND Account_Status = 'A';


-- STEP 19: Compare original and corrected text values
-- <> identifies status differences according to
-- SQL Server string-comparison rules.
-- Trailing-space-only changes may not appear.
-- Expected: 2 rows (1002, 1004).
-- Account 1005 is not detected because SQL Server
-- generally ignores trailing spaces in text comparisons.

SELECT
    O.Account_ID,
    O.Account_Status AS Original_Status,
    C.Account_Status AS Corrected_Status
FROM #Legacy_Status AS O
INNER JOIN #Legacy_Status_Corrected AS C
    ON O.Account_ID = C.Account_ID
WHERE O.Account_Status <> C.Account_Status;


-- STEP 20: Detect text or byte-length differences
-- OR combines both validation conditions.
-- Expected: 3 rows (1002, 1004, 1005).
-- Combining text and byte-length comparisons
-- detects all three corrections in this dataset.

SELECT
    O.Account_ID,
    O.Account_Status AS Original_Status,
    C.Account_Status AS Corrected_Status,
    DATALENGTH(O.Account_Status) AS Original_Bytes,
    DATALENGTH(C.Account_Status) AS Corrected_Bytes
FROM #Legacy_Status AS O
INNER JOIN #Legacy_Status_Corrected AS C
    ON O.Account_ID = C.Account_ID
WHERE O.Account_Status <> C.Account_Status
   OR DATALENGTH(O.Account_Status) <> DATALENGTH(C.Account_Status);


-- STEP 21: Validate approved account status values
-- Expected result: Zero rows.
-- This check does not detect NULL statuses.

SELECT
    Account_ID,
    Account_Status
FROM #Legacy_Status_Corrected
WHERE Account_Status NOT IN (
    'Active',
    'Inactive',
    'Suspended'
);


-- STEP 22: Compare original and corrected row counts
-- COUNT(*) counts all rows.
-- UNION ALL combines both results without
-- removing duplicate result rows.
-- Expected result: Six records in each table.

SELECT
    'Original' AS Dataset,
    COUNT(*) AS Total_Accounts
FROM #Legacy_Status

UNION ALL

SELECT
    'Corrected' AS Dataset,
    COUNT(*) AS Total_Accounts
FROM #Legacy_Status_Corrected;


-- STEP 23: Find original accounts missing from corrected
-- LEFT JOIN preserves all original accounts.
-- NULL identifies accounts without a corrected match.
-- Expected result: Zero rows.

SELECT
    O.Account_ID AS Original_Account,
    C.Account_ID AS Corrected_Account
FROM #Legacy_Status AS O
LEFT JOIN #Legacy_Status_Corrected AS C
    ON O.Account_ID = C.Account_ID
WHERE C.Account_ID IS NULL;


-- STEP 24: Find unexpected accounts in corrected
-- Reverse the LEFT JOIN to preserve corrected accounts.
-- Expected result: Zero rows.

SELECT
    C.Account_ID AS Corrected_Account,
    O.Account_ID AS Original_Account
FROM #Legacy_Status_Corrected AS C
LEFT JOIN #Legacy_Status AS O
    ON C.Account_ID = O.Account_ID
WHERE O.Account_ID IS NULL;


-- =====================================================
-- TRANSFORMATION SUMMARY
-- =====================================================
--
-- Account 1002: A -> Active
-- Assumed approved mapping rule applied.
--
-- Account 1004: Actve -> Active
-- Simulated approved spelling correction.
--
-- Account 1005: Active [trailing space] -> Active
-- TRIM() applied to remove trailing whitespace.
--
-- =====================================================
-- VALIDATION RESULTS
-- =====================================================
--
-- Original records:              6
-- Corrected records:             6
-- Status corrections:            3
-- Missing account IDs:           0
-- Unexpected account IDs:        0
-- Unapproved statuses detected:  0
--
-- NOTE:
-- This exercise uses fictional data and assumed
-- approvals for learning purposes.
-- Original data was preserved.
--
-- END OF SQL LAB 02
-- =====================================================
