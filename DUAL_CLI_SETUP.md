# Dual CLI Setup Guide

## Overview

This project implements **two separate CLI tools** for managing vegetables data with Cloud Firestore:

- **`vegetables_dev`**: Development CLI with automatic emulator integration
- **`vegetables_prod`**: Production CLI with strict safety validations

Both CLIs use the same codebase but with different configurations to prevent accidental data corruption.

---

## Architecture

### Key Concepts

**dart_firebase_admin Behavior:**
- Uses Firebase Admin SDK for server-side operations
- Automatically detects `FIRESTORE_EMULATOR_HOST` environment variable
- Routes to emulator when env var is set, production otherwise
- Same initialization code works for both environments

**Credential Handling:**
- **Development**: Auto-provides dummy credentials when emulator detected
- **Production**: Requires real service account credentials
- Credentials never saved to disk (security best practice)

**Collection Names:**
- **Development**: Uses `vegetables_test` collection (safe for testing)
- **Production**: Uses `vegetables` collection (real data)

---

## Development Environment Setup

### Prerequisites

- Dart SDK ^3.10.0
- Node.js and npm (for Firebase CLI)
- Internet connection (for initial setup)

### Step 1: Install Firebase CLI

#### Linux (Ubuntu)

```bash
# Install Node.js if not already installed
sudo apt update
sudo apt install -y nodejs npm

# Install Firebase CLI globally
sudo npm install -g firebase-tools

# Verify installation
firebase --version
```

#### Windows

```cmd
# 1. Install Node.js from https://nodejs.org/
# 2. Open new terminal and install Firebase CLI
npm install -g firebase-tools

# Verify installation
firebase --version
```

### Step 2: Login to Firebase

```bash
firebase login
```

This opens a browser for Google authentication. Sign in with your Firebase account.

### Step 3: Initialize Firebase Emulators

#### Linux (Ubuntu)

```bash
# Navigate to project directory
cd ~/bluecorn/git/vegetables_firestore

# Initialize emulators
firebase init emulators
```

#### Windows

```cmd
# Navigate to project directory
cd C:\Users\hugo\bluecorn\git\vegetables_firestore

# Initialize emulators
firebase init emulators
```

**Configuration:**
- Select: **Firestore Emulator**
- Port: **8080** (default)
- Enable Emulator UI: **Yes** (optional, but recommended)

### Step 4: Daily Development Workflow

#### Terminal 1: Start Emulator

```bash
firebase emulators:start
```

**Expected Output:**
```
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect.         │
└─────────────────────────────────────────────────────────────┘

┌───────────┬────────────────┬─────────────────────────────────┐
│ Emulator  │ Host:Port      │ View in Emulator UI             │
├───────────┼────────────────┼─────────────────────────────────┤
│ Firestore │ localhost:8080 │ http://localhost:4000/firestore │
└───────────┴────────────────┴─────────────────────────────────┘
```

Leave this terminal running while developing.

#### Terminal 2: Set Environment Variable

**Linux (Ubuntu) - Bash:**
```bash
# Set for current session
export FIRESTORE_EMULATOR_HOST=localhost:8080

# Verify it's set
echo $FIRESTORE_EMULATOR_HOST

# Optional: Add to ~/.bashrc for persistence
echo 'export FIRESTORE_EMULATOR_HOST=localhost:8080' >> ~/.bashrc
source ~/.bashrc
```

**Windows - Command Prompt (CMD):**
```cmd
# Set for current session
set FIRESTORE_EMULATOR_HOST=localhost:8080

# Verify it's set
echo %FIRESTORE_EMULATOR_HOST%

# Optional: Persist across sessions
setx FIRESTORE_EMULATOR_HOST "localhost:8080"
```

**Windows - PowerShell:**
```powershell
# Set for current session
$env:FIRESTORE_EMULATOR_HOST="localhost:8080"

# Verify it's set
$env:FIRESTORE_EMULATOR_HOST

# Optional: Persist for current user
[System.Environment]::SetEnvironmentVariable('FIRESTORE_EMULATOR_HOST', 'localhost:8080', 'User')
```

#### Terminal 2: Run Development CLI

**Linux (Ubuntu):**
```bash
# No credentials needed - auto-detected!
dart run bin/vegetables_dev.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --upload-to-firestore
```

**Windows:**
```cmd
dart run bin/vegetables_dev.dart import ^
  --input vegetables.txt ^
  --output vegetables.json ^
  --upload-to-firestore
```

**What happens:**
1. CLI detects `FIRESTORE_EMULATOR_HOST` is set
2. Automatically provides dummy credentials (no prompt)
3. Connects to local emulator (no internet needed)
4. Uses `vegetables_test` collection (safe)
5. Data stays on your local machine

---

## Production Environment Setup

### ⚠️ WARNING

Production CLI writes to **real Firebase Firestore** and modifies **live data**. Only use when:
- Emulator is NOT running
- You have proper service account credentials
- You intend to modify production data

### Step 1: Obtain Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Firebase project
3. Navigate to: **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file

**IMPORTANT:** Never commit service account files to version control!

### Step 2: Store Credentials Securely

#### Linux (Ubuntu)

```bash
# Create secure credentials directory
mkdir -p ~/firebase-credentials
chmod 700 ~/firebase-credentials

# Move downloaded file
mv ~/Downloads/your-project-*.json ~/firebase-credentials/prod-service-account.json

# Set restrictive permissions
chmod 600 ~/firebase-credentials/prod-service-account.json
```

#### Windows

```cmd
# Create credentials directory
mkdir %USERPROFILE%\firebase-credentials

# Move downloaded file to:
# %USERPROFILE%\firebase-credentials\prod-service-account.json
```

### Step 3: Ensure Emulator is NOT Active

**Before running production CLI**, verify emulator environment variable is **NOT set**:

#### Linux (Ubuntu)

```bash
# Unset environment variable
unset FIRESTORE_EMULATOR_HOST

# Verify it's unset (should print empty line)
echo $FIRESTORE_EMULATOR_HOST

# Remove from .bashrc if you added it
sed -i '/FIRESTORE_EMULATOR_HOST/d' ~/.bashrc
```

#### Windows - Command Prompt (CMD)

```cmd
# Unset environment variable
set FIRESTORE_EMULATOR_HOST=

# Verify it's unset (should print %FIRESTORE_EMULATOR_HOST%)
echo %FIRESTORE_EMULATOR_HOST%

# Remove persistent variable
setx FIRESTORE_EMULATOR_HOST ""
```

#### Windows - PowerShell

```powershell
# Unset environment variable
Remove-Item Env:\FIRESTORE_EMULATOR_HOST

# Verify it's unset (should print nothing)
$env:FIRESTORE_EMULATOR_HOST

# Remove persistent variable
[System.Environment]::SetEnvironmentVariable('FIRESTORE_EMULATOR_HOST', $null, 'User')
```

### Step 4: Run Production CLI

#### Option A: Using Service Account File

**Linux (Ubuntu):**
```bash
dart run bin/vegetables_prod.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --upload-to-firestore \
  --firebase-project-id your-project-id \
  --firebase-service-account ~/firebase-credentials/prod-service-account.json
```

**Windows:**
```cmd
dart run bin/vegetables_prod.dart import ^
  --input vegetables.txt ^
  --output vegetables.json ^
  --upload-to-firestore ^
  --firebase-project-id your-project-id ^
  --firebase-service-account %USERPROFILE%\firebase-credentials\prod-service-account.json
```

#### Option B: Paste Credentials Interactively (More Secure)

**Linux (Ubuntu):**
```bash
dart run bin/vegetables_prod.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --upload-to-firestore \
  --firebase-project-id your-project-id
```

**Windows:**
```cmd
dart run bin/vegetables_prod.dart import ^
  --input vegetables.txt ^
  --output vegetables.json ^
  --upload-to-firestore ^
  --firebase-project-id your-project-id
```

The CLI will prompt:
```
Enter service account JSON (paste entire JSON on one line):
```

Paste the entire contents of your service account JSON file and press Enter.

**What happens:**
1. CLI validates emulator is NOT running (safety check)
2. Prompts for real credentials (or reads from file)
3. Connects to production Firestore
4. Uses `vegetables` collection (real data)
5. Modifies live production data

---

## Quick Reference: Environment Variables

### Setting Environment Variables

| Platform | Shell      | Set Variable                                  | Unset Variable                        | Check Variable                 |
|----------|------------|-----------------------------------------------|---------------------------------------|--------------------------------|
| Linux    | Bash       | `export FIRESTORE_EMULATOR_HOST=localhost:8080` | `unset FIRESTORE_EMULATOR_HOST`       | `echo $FIRESTORE_EMULATOR_HOST`  |
| Windows  | CMD        | `set FIRESTORE_EMULATOR_HOST=localhost:8080`    | `set FIRESTORE_EMULATOR_HOST=`        | `echo %FIRESTORE_EMULATOR_HOST%` |
| Windows  | PowerShell | `$env:FIRESTORE_EMULATOR_HOST="localhost:8080"` | `Remove-Item Env:\FIRESTORE_EMULATOR_HOST` | `$env:FIRESTORE_EMULATOR_HOST`   |

### Making Variables Persistent

| Platform | Shell      | Make Persistent                                                                                       |
|----------|------------|-------------------------------------------------------------------------------------------------------|
| Linux    | Bash       | `echo 'export FIRESTORE_EMULATOR_HOST=localhost:8080' >> ~/.bashrc && source ~/.bashrc`              |
| Windows  | CMD        | `setx FIRESTORE_EMULATOR_HOST "localhost:8080"`                                                       |
| Windows  | PowerShell | `[System.Environment]::SetEnvironmentVariable('FIRESTORE_EMULATOR_HOST', 'localhost:8080', 'User')`   |

---

## Troubleshooting

### "Cannot connect to emulator" Error

**Symptoms:**
```
Error: Failed to initialize Firestore: Connection refused
```

**Solutions:**
1. Verify emulator is running: `firebase emulators:start`
2. Check environment variable is set: `echo $FIRESTORE_EMULATOR_HOST` (Linux) or `echo %FIRESTORE_EMULATOR_HOST%` (Windows)
3. Verify emulator port is 8080 (or update env var to match)
4. Check firewall isn't blocking localhost:8080

### "Emulator must be running for dev CLI" Error

**Symptoms:**
```
EnvironmentException: Development mode requires Firebase Emulator to be running.
```

**Solutions:**
1. Start emulator: `firebase emulators:start`
2. Set environment variable (see Quick Reference above)
3. Use production CLI instead if you intend to access production data

### "Emulator must NOT be running for prod CLI" Error

**Symptoms:**
```
EnvironmentException: Production mode cannot be used with emulator active.
```

**Solutions:**
1. Unset environment variable: `unset FIRESTORE_EMULATOR_HOST` (Linux) or `set FIRESTORE_EMULATOR_HOST=` (Windows)
2. Restart terminal to ensure variable is cleared
3. Use development CLI instead if you want to test with emulator

### "Invalid service account credentials" Error

**Symptoms:**
```
Error: Failed to initialize Firestore: Invalid credentials
```

**Solutions:**
1. Verify JSON file is complete and valid
2. Check file has correct permissions (Linux: `chmod 600`)
3. Ensure you downloaded the file from correct Firebase project
4. Regenerate service account key if file is corrupted

---

## Next Steps

After completing environment setup:

1. **Verify emulator is working:**
   ```bash
   firebase emulators:start
   # Should show Firestore running on localhost:8080
   ```

2. **Test development CLI:**
   ```bash
   dart run bin/vegetables_dev.dart --help
   ```

3. **Review implementation plan:**
   - See `.claude/tdd-tasks/dual-cli.md` for TDD implementation phases
   - Follow Red-Green-Refactor cycle for each task

4. **Run existing tests:**
   ```bash
   dart test
   ```

---

## Security Best Practices

1. **Never commit service account files** - `.gitignore` is configured to exclude them
2. **Use file permissions** - Linux users should `chmod 600` service account files
3. **Store credentials outside project directory** - Recommended: `~/firebase-credentials/` (Linux) or `%USERPROFILE%\firebase-credentials\` (Windows)
4. **Use emulator for all development** - Only use production CLI when necessary
5. **Verify environment before running production CLI** - Double-check `FIRESTORE_EMULATOR_HOST` is unset

---

## Additional Resources

- [Firebase Emulator Suite Documentation](https://firebase.google.com/docs/emulator-suite)
- [dart_firebase_admin Package](https://pub.dev/packages/dart_firebase_admin)
- [Firebase Service Accounts](https://firebase.google.com/docs/admin/setup#initialize-sdk)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## Implementation Plan

For developers ready to implement the dual CLI architecture, see:

**`.claude/tdd-tasks/dual-cli.md`** - Complete TDD implementation plan with:
- 9 implementation phases
- Detailed test specifications
- dart_firebase_admin integration details
- File changes summary
- Success criteria
