# Project Context

Project Name:
Salesforce Excel Export

Business Objective:
Keep an Excel file in sync with Salesforce Account records: initial load of the latest 50, then incremental upsert of changed Accounts on each trigger.

Source System:
Salesforce

Object:
Account

Target:
Excel File (.xlsx)

Integration Pattern:
Scheduled Batch

Schedule:
On Demand (manual trigger for initial version)

Volume:
Up to 50 records per execution

Deployment:
CloudHub 2.0

Requirements:

- Initial load (missing or empty workbook): retrieve latest 50 Account records sorted by LastModifiedDate descending
- Incremental runs: retrieve up to 50 Accounts modified since the last successful run (watermark in persistent Object Store, committed after the file write)
- Upsert into the existing Excel file by Account Id: update changed rows in place, append new Accounts at the end, keep other rows
- Generate Excel file (read-merge-rewrite; XLSX cannot be appended in place)
- Store file locally or in configured output location
- Include Account Id
- Include Account Name
- Include Phone
- Include Billing City
- Handle Salesforce connection failures
- Generate MUnit tests