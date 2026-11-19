# Project Context

Project Name:
Salesforce Excel Export

Business Objective:
Export the latest 50 Salesforce Account records into an Excel file.

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
50 records per execution

Deployment:
CloudHub 2.0

Requirements:

- Retrieve latest 50 Account records
- Sort by LastModifiedDate descending
- Generate Excel file
- Store file locally or in configured output location
- Include Account Id
- Include Account Name
- Include Phone
- Include Billing City
- Handle Salesforce connection failures
- Generate MUnit tests