
-- =====================================================
-- BALBOA BAY PARTNERS
-- SQL LAB 01: ACCOUNT RECONCILIATION & VALIDATION
-- =====================================================
-- OBJECTIVE:
-- Compare legacy and target customer account IDs
-- to identify missing and unexpected accounts.
--
-- DATA: Fictional utility customer accounts
-- METHOD: SQL LEFT JOIN reconciliation
--
-- CONTROL OBJECTIVE:
-- Verify account identity completeness between
-- the legacy and target systems.
-- =====================================================


-- STEP 1: Reset temporary tables
-- Allows the complete script to run repeatedly
-- without existing-table errors.

DROP TABLE IF EXISTS #Legacy_Accounts;
DROP TABLE IF EXISTS #Target_Accounts;


-- STEP 2: Create and populate legacy accounts
-- Account_ID is stored as an integer.
-- Expected: 4 rows inserted.

CREATE TABLE #Legacy_Accounts (
    Account_ID INT
);

INSERT INTO #Legacy_Accounts (Account_ID)
VALUES (1001), (1002), (1003), (1004);


-- STEP 3: Inspect original legacy accounts
-- Expected: 4 accounts (1001, 1002, 1003, 1004).

SELECT *
FROM #Legacy_Accounts;


-- STEP 4: Create and populate target accounts
-- Expected: 4 rows inserted.

CREATE TABLE #Target_Accounts (
    Account_ID INT
);

INSERT INTO #Target_Accounts (Account_ID)
VALUES (1001), (1002), (1004), (1005);


-- STEP 5: Inspect target accounts
-- Expected: 4 accounts (1001, 1002, 1004, 1005).
-- Record counts verified visually in Steps 3 and 5.

SELECT *
FROM #Target_Accounts;


-- STEP 6: Find accounts missing from the target
-- LEFT JOIN preserves legacy accounts.
-- NULL identifies legacy accounts without a match.
--
-- Expected: 1 row (1003).
-- Legacy_Account = 1003
-- Target_Account = NULL

SELECT
    L.Account_ID AS Legacy_Account,
    T.Account_ID AS Target_Account
FROM #Legacy_Accounts AS L
LEFT JOIN #Target_Accounts AS T
    ON L.Account_ID = T.Account_ID
WHERE T.Account_ID IS NULL;


-- STEP 7: Find unexpected accounts in the target
-- Reverse the LEFT JOIN to preserve target accounts.
-- NULL identifies target accounts without a match.
--
-- Expected: 1 row (1005).
-- Target_Account = 1005
-- Legacy_Account = NULL

SELECT
    T.Account_ID AS Target_Account,
    L.Account_ID AS Legacy_Account
FROM #Target_Accounts AS T
LEFT JOIN #Legacy_Accounts AS L
    ON T.Account_ID = L.Account_ID
WHERE L.Account_ID IS NULL;


-- =====================================================
-- EXPECTED VALIDATION RESULTS
-- =====================================================
--
-- Legacy account records:          4
-- Target account records:          4
--
-- Missing from target:             1 (1003)
-- Unexpected in target:            1 (1005)
--
-- Matched account IDs:             3
-- Account identity discrepancies:  2
--
-- =====================================================
-- VALIDATION SUMMARY
-- =====================================================
--
-- CONTROL 1: LEGACY-TO-TARGET COMPLETENESS
-- Result: 1 unmatched legacy account (1003).
-- Expected control outcome: Exception detected.
--
-- CONTROL 2: TARGET-TO-LEGACY RECONCILIATION
-- Result: 1 unmatched target account (1005).
-- Expected control outcome: Exception detected.
--
-- FINDING:
-- Both datasets contain four records, but their
-- account identities do not fully reconcile.
--
-- Matching row counts do not guarantee
-- matching customer accounts.
--
-- BUSINESS IMPACT:
-- Missing or unexpected accounts may contribute
-- to billing or operational discrepancies.
-- Actual impact has not been established.
--
-- LIMITATIONS:
-- This lab validates account ID presence only.
-- It does not validate account statuses,
-- financial balances, invoices, or authorization.
--
-- Both exceptions require further investigation
-- before being classified as migration defects.
--
-- NOTE:
-- Fictional data used for learning purposes.
-- No actual customer or utility records involved.
--
-- END OF SQL LAB 01
-- =====================================================
