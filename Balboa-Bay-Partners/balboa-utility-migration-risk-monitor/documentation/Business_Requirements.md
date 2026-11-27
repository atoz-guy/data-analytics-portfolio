# Business Requirements

> Fictional scenario for learning purposes. Not affiliated with or endorsed by Balboa Bay Partners.

## Background

A utility is moving customer data from a legacy Customer Information System (CIS) to a modern platform such as SAP. Before the new system goes live, the business needs proof that customer accounts arrived complete, correct and in the right status. Errors here lead directly to wrong bills, missed shut-offs or customers being billed after they cancelled.

## Objective

Use SQL to find, document and resolve data risks in the migration, and report the results the way a consulting validation team would.

## Requirements

| ID | Requirement | Covered by |
|---|---|---|
| BR-01 | Every legacy account must exist in the target system, and the target must not contain accounts that never existed in legacy. | Lab 01 |
| BR-02 | Account status values must use only approved values (`Active`, `Inactive`, `Suspended`), with abbreviations, typos and hidden spaces corrected. | Lab 02 |
| BR-03 | Original source data must never be changed. Corrections are made on a working copy, with before/after evidence. | Lab 02 |
| BR-04 | Status differences between legacy and target must be detected, logged as exceptions and tracked from Open to Resolved. | Lab 03 |
| BR-05 | An exception can only be closed after evidence, findings, a documented decision and an approval are recorded. | Lab 03 |
| BR-06 | Migration controls must be tested to confirm they work as designed, and control failures must be remediated and verified before closure without erasing the original failure. | Lab 04 |
| BR-07 | Exceptions must be scored by risk so the most serious issues are handled first. | Lab 05 (planned) |
| BR-08 | Fixes must be tracked to completion, with owner and status. | Lab 06 (planned) |
| BR-09 | Management must get a summary of migration risk and progress. | Lab 07 (planned), Power BI dashboard (future) |

## In scope

- Account identity and account status data
- Detection, correction, exception tracking and validation using T-SQL
- Documentation of assumptions, findings and limitations

## Out of scope

- Real customer data. All data is fictional.
- Real approvals or evidence. These are simulated.
- Production controls such as audit logging and access control.

## Success criteria

- Each lab states its expected results before each query, and the actual results match.
- Every finding, assumption and limitation is documented honestly.
