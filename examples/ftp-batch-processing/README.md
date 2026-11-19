# FTP/SFTP Batch Processing

## Pattern
Secure file ingestion, validation, transformation, and archive.

## Architecture
SFTP -> batch Process API -> target System APIs.

## Data Flow
Move files to a work location, validate schema/record count, stream batch records, aggregate errors, and archive or quarantine.

## Controls
SSH/TLS, least-privilege keys, file naming, duplicate detection, checkpointing, bounded batch failure, dead letter, and retention.
