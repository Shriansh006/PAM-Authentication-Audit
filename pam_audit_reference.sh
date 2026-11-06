#!/bin/bash

#################################################################################
#
# Reference script 1 - PAM Authentication Audit
#
# Base script for the Lynis PAM audit exercise. Reads /etc/pam.d and runs four
# checks: pam_permit.so, nullok, remember= and pam_unix.so.
#
# Usage:
#     bash pam_audit_reference.sh
#
#################################################################################

echo "===================================="
echo "     PAM Authentication Audit"
echo "===================================="

PAM_DIR="/etc/pam.d"

if [ ! -d "$PAM_DIR" ]; then
    echo "[FAIL] PAM directory not found."
    exit 1
fi

echo

echo "Checking for insecure pam_permit.so..."

if grep -R "pam_permit.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] pam_permit.so found!"
else
    echo "[PASS] No pam_permit.so entries found."
fi

echo

echo "Checking for empty password support (nullok)..."

if grep -R "nullok" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] Empty passwords may be allowed."
else
    echo "[PASS] Empty passwords are not allowed."
fi

echo

echo "Checking password history enforcement..."

if grep -R "remember=" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Password history is configured."
else
    echo "[INFO] Password history not configured."
fi

echo

echo "Checking for pam_unix.so..."

if grep -R "pam_unix.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] pam_unix.so is present."
else
    echo "[WARNING] pam_unix.so not found."
fi

echo
echo "Audit Completed."
