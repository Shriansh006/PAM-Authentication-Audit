#!/bin/bash

echo "===================================="
echo "     PAM Authentication Audit"
echo "===================================="

PAM_DIR="/etc/pam.d"
WARNINGS=0

if [ ! -d "$PAM_DIR" ]; then
    echo "[FAIL] PAM directory not found."
    exit 1
fi

echo
echo "--- Module Security Checks ---"
echo

echo "Checking for insecure pam_permit.so..."
if grep -R "pam_permit.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] pam_permit.so found — grants unconditional access."
    WARNINGS=$((WARNINGS + 1))
else
    echo "[PASS] No pam_permit.so entries found."
fi

echo
echo "Checking for pam_deny.so usage..."
if grep -R "pam_deny.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] pam_deny.so is in use (default-deny policy active)."
else
    echo "[INFO] pam_deny.so not found — no explicit deny rules."
fi

echo
echo "Checking for pam_unix.so..."
if grep -R "pam_unix.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] pam_unix.so is present."
else
    echo "[WARNING] pam_unix.so not found — standard auth may be missing."
    WARNINGS=$((WARNINGS + 1))
fi

echo
echo "--- Password Policy Checks ---"
echo

echo "Checking for empty password support (nullok)..."
if grep -R "nullok" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] Empty passwords may be allowed (nullok detected)."
    WARNINGS=$((WARNINGS + 1))
else
    echo "[PASS] Empty passwords are not allowed."
fi

echo
echo "Checking password history enforcement..."
if grep -R "remember=" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Password history is configured."
else
    echo "[WARNING] Password history not configured — reuse may be possible."
    WARNINGS=$((WARNINGS + 1))
fi

echo
echo "Checking for password strength module (pam_pwquality / pam_cracklib)..."
if grep -R "pam_pwquality.so\|pam_cracklib.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Password strength enforcement module is active."
else
    echo "[WARNING] No password strength module found."
    WARNINGS=$((WARNINGS + 1))
fi

echo
echo "Checking for minimum password length (minlen=)..."
if grep -R "minlen=" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Minimum password length is enforced."
else
    echo "[INFO] minlen not set — default system length applies."
fi

echo
echo "Checking for retry limit on password prompts (retry=)..."
if grep -R "retry=" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Retry limit is configured."
else
    echo "[INFO] retry not set — unlimited attempts may be allowed."
fi

echo
echo "--- Account Lockout Checks ---"
echo

echo "Checking for account lockout (pam_faillock / pam_tally2)..."
if grep -R "pam_faillock.so\|pam_tally2.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Account lockout mechanism is active."
else
    echo "[WARNING] No account lockout module detected."
    WARNINGS=$((WARNINGS + 1))
fi

echo
echo "--- Hashing & Encryption Checks ---"
echo

echo "Checking for SHA512 password hashing..."
if grep -R "sha512" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] SHA512 hashing is configured."
elif grep -R "sha256" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] SHA256 hashing is configured."
else
    echo "[INFO] No explicit hashing algorithm set (system default applies)."
fi

echo
echo "Checking for insecure MD5 hashing..."
if grep -R "md5" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] MD5 hashing detected — upgrade to SHA512."
    WARNINGS=$((WARNINGS + 1))
else
    echo "[PASS] No MD5 hashing detected."
fi

echo
echo "--- Access Control Checks ---"
echo

echo "Checking for pam_wheel.so (restrict su access)..."
if grep -R "pam_wheel.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] su access is restricted via pam_wheel."
else
    echo "[INFO] pam_wheel.so not found — su may not be restricted."
fi

echo
echo "Checking for debug flag in PAM modules..."
if grep -R "\bdebug\b" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] Debug flag found — may expose sensitive info in logs."
    WARNINGS=$((WARNINGS + 1))
else
    echo "[PASS] No debug flags detected."
fi

echo
echo "--- Session & Logging Checks ---"
echo

echo "Checking for pam_lastlog.so (login logging)..."
if grep -R "pam_lastlog.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Login logging (pam_lastlog) is active."
else
    echo "[INFO] pam_lastlog.so not found — login records may be limited."
fi

echo
echo "Checking for pam_env.so (environment setup)..."
if grep -R "pam_env.so" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[PASS] Environment setup module is active."
else
    echo "[INFO] pam_env.so not configured."
fi

echo
echo "--- Control Flag Checks ---"
echo

echo "Checking for 'sufficient' used with weak modules..."
if grep -R "sufficient.*pam_permit\|sufficient.*pam_succeed_if" "$PAM_DIR" >/dev/null 2>&1; then
    echo "[WARNING] 'sufficient' flag used with potentially weak module."
    WARNINGS=$((WARNINGS + 1))
else
    echo "[PASS] No risky sufficient rules detected."
fi

echo
echo "--- Summary ---"
echo
echo "Total warnings: $WARNINGS"

if [ "$WARNINGS" -eq 0 ]; then
    echo "Result: All checks passed."
elif [ "$WARNINGS" -le 3 ]; then
    echo "Result: Minor issues detected — review recommended."
else
    echo "Result: Multiple security issues found — immediate review advised."
fi

echo
echo "Audit Completed."
