# Intelligent File Analyzer & Cleanup Assistant

A local-first, privacy-focused desktop application that scans real folders and drives on your computer to detect redundant, temporary, corrupted, suspicious, duplicate, and potentially useless files.

Built with **React 18, TypeScript, Tailwind CSS, Node.js, Express, and built-in SQLite (`node:sqlite`)**.

---

## Key Features & Detection Vectors

### 1. Exact Duplicate Files (SHA-256)
- **Hierarchical Hashing**: Files are grouped by exact byte size first. Groups with duplicate sizes receive a fast partial hash (head + size + tail). Candidate matches then undergo streaming SHA-256 calculation.
- **Original Preservation**: Oldest file is designated as the master copy; duplicates are flagged with duplicate group IDs and the master file's name.

### 2. Temporary & Junk Files
- Detects `.tmp`, `.temp`, `.bak`, `.old`, `.swp`, `thumbs.db`, `.DS_Store`, leftover Office lock files (`~$*`), obsolete log rotations (`.log.1`, `.log.2`), and Windows crash dump stacks (`.dmp`).
- Safely cleans application cache and temporary folders without deleting critical executables.

### 3. Potentially Unused (Old) Files
- Analyzes last modified, creation, and last accessed timestamps.
- Flags files not modified within a configurable window (default: 180 days).
- **Non-destructive classification**: Labeled explicitly as *"Potentially unused"* rather than assuming uselessness.

### 4. Corrupted File Inspection
- **PNG**: Validates `0x89504E47` header signature, chunk CRCs, and terminal `IEND` chunk.
- **JPEG**: Validates `0xFFD8` SOI (Start of Image) header and `0xFFD9` EOI (End of Image) trailer.
- **GIF**: Validates `GIF87a`/`GIF89a` prologue and terminal trailer byte `0x3B`.
- **PDF**: Inspects `%PDF-` header and terminal `%%EOF` end-of-file marker.
- **ZIP / Office XML (.docx, .xlsx, .pptx)**: Validates `PK\x03\x04` local headers and verifies the presence of the End of Central Directory (EOCD `PK\x05\x06`) record in the trailing bytes.
- **JSON**: Validates structural parse integrity.

### 5. Suspicious & High-Entropy Files
- **Header vs Extension Mismatch**: Flags executables masquerading as images or documents (e.g., a `.jpg` or `.pdf` file whose magic bytes start with Windows PE `MZ`).
- **Double Extensions**: Detects dangerous naming patterns like `invoice.pdf.exe` or `statement.doc.vbs`.
- **Shannon Entropy Analysis**: Computes byte entropy ($H \in [0.0, 8.0]$). If $H > 7.5$ on non-compressed files or files with missing extensions, flags as *"Possibly encrypted or compressed"* with full technical justification.

### 6. Large Files
- Configurable threshold (default: 100 MB). Shows exact size, directory, extension, and last modified date.

### 7. Similar Content & Near-Duplicates
- Employs word shingle tokenization and Jaccard lexical overlap to detect revised documents, near-duplicate text files, and duplicate logs.

---

## Safety & Protection Architecture

### Absolute Safety Rules
1. **Never Automatically Delete Files**: The application never cleans or deletes without user selection and confirmation.
2. **Explicit Confirmation Workflow**:
   $$\text{SCAN} \longrightarrow \text{ANALYZE} \longrightarrow \text{SHOW RESULTS} \longrightarrow \text{SELECT FILES} \longrightarrow \text{CONFIRM MODAL} \longrightarrow \text{CLEANUP}$$
3. **Comprehensive Confirmation Modal**:
   Before executing any cleanup, the confirmation dialog displays:
   - File name & full absolute path
   - File size & format type
   - Category & risk score
   - Reason for detection & last modified date
   - Total recoverable storage calculation
4. **Quarantine by Default**:
   Cleaned files are safely moved to the local **Quarantine Vault** with metadata stored in SQLite. You can restore any file back to its exact original path at any time.
5. **Separated Permanent Delete Option**:
   Permanent file destruction requires explicitly toggling the permanent delete tab and accepting an additional warning checkbox.
6. **OS Protection Layer**:
   Critical system paths (`C:\Windows`, `C:\Windows\System32`, `C:\Program Files`, `C:\Program Files (x86)`, Boot files, Registry transaction logs, `pagefile.sys`, `hiberfil.sys`) are protected against accidental deletion. Deletion is blocked unless an advanced override is checked.

---

## Local Database (SQLite)

All application data is stored locally in `.app-data/analyzer_database.db` using Node 22/24's native `node:sqlite` (`DatabaseSync`):
- `scan_history`: Records past scan timestamps, paths, file counts, and recoverable storage.
- `quarantine_records`: Tracks quarantined files, original paths, unique quarantine storage paths, and hashes.
- `cleanup_history`: Full audit trail of every quarantine, permanent delete, or restore action.
- `settings`: Configurable detection thresholds and quarantine path.

**100% Local-First & Private**: No files, file names, or telemetry are ever uploaded or sent over the internet.

---

## Quick Start & Running

### Prerequisites
- Node.js 22+ or 24+ installed on your system.

### One-Click Launch (Windows)
Double-click `start.bat` or run:
```powershell
.\start.ps1
```
This starts the local backend server and automatically opens your web browser at **`http://127.0.0.1:3847`**.

### Manual Launch (Command Line)
```bash
# 1. Install dependencies (if not already installed)
npm install

# 2. Build the frontend dashboard
npm run build

# 3. Start the application
npm start
```
Then open `http://127.0.0.1:3847` in your browser.

---

## Testing & Verification

The project includes an automated end-to-end test suite that generates a realistic `test-data/` folder containing samples across all 8 detection categories, scans it, and validates every single feature:

```bash
npm run test:verify
```

### Verification Checklist Output:
1. `[1/12]` Generates test files inside `test-data/`
2. `[2/12]` Recursive scanner & multi-vector analyzer execution
3. `[3/12]` SHA-256 duplicate detection & master copy preservation
4. `[4/12]` Junk / temporary files detection (`.tmp`, `.dmp`, `thumbs.db`)
5. `[5/12]` Corrupted files detection (truncated PNG, missing PDF EOF, invalid ZIP EOCD)
6. `[6/12]` Suspicious files detection (MZ header disguised as `.jpg`, double extension `.pdf.exe`, high Shannon entropy)
7. `[7/12]` Old / unused files detection (modified > 400 days ago)
8. `[8/12]` Large files detection (52 MB file)
9. `[9/12]` Moving file to Quarantine vault & SQLite registration
10. `[10/12]` Restoring file from Quarantine back to original path with identical content
11. `[11/12]` Permanent file deletion & cleanup audit logging
12. `[12/12]` Operating System protection layer safety refusal

---

## Scanning Real Files on Your Computer

1. Open the application at `http://127.0.0.1:3847`.
2. In the **Filesystem Scan Target** section, click any of the quick shortcuts:
   - **Downloads** (`C:\Users\<user>\Downloads`)
   - **Documents** (`C:\Users\<user>\Documents`)
   - **Desktop** (`C:\Users\<user>\Desktop`)
   - **Temp Directory** (`AppData\Local\Temp`)
   - **Drive C:\\**
   - Or enter any custom path in the input box.
3. Click **Start Full Scan**.
4. Watch real-time progress:
   - Live counter: `X / Y files scanned`
   - Real-time disk storage analyzed
   - Current file path indicator
   - Stop / Cancel button at any time.
5. Review results in the interactive Dashboard and Results Table.
6. Use filters (`Duplicates`, `Junk`, `Corrupted`, `Suspicious`, `Large`, `Old`, `Protected`) and search.
7. Click any file to view its full technical dossier (Entropy, Magic Bytes, SHA-256, timestamps).
8. Select items and click **Clean Selected** to safely move them to Quarantine.
