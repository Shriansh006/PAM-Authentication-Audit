# PAM Authentication Audit — Lynis Enhancements

Two enhancements that audit the PAM (Pluggable Authentication Modules)
configuration on a Linux host. They look for empty-password support, missing
password history, weak or absent password-strength enforcement, missing account
lockout, insecure MD5 hashing, leftover debug options and more.

Built on top of the official Lynis repository: <https://github.com/CISOfy/lynis>

## Contents

| File                   | Enhancement                          | Type               |
|------------------------|--------------------------------------|--------------------|
| `pam_audit_enhanced.sh`| Option 1 — expanded standalone audit | Bash script        |
| `tests_custom`         | Option 2 — native Lynis test module  | Lynis `tests_custom` |

## Enhancement Option 1 — `pam_audit_enhanced.sh`

A standalone Bash script. It walks `/etc/pam.d`, prints a coloured
`[PASS] / [WARNING] / [INFO]` line for every check, groups the checks into
sections (module security, password policy, account lockout, hashing, access
control, session/logging, control flags) and finishes with a warning count and
an overall verdict.

```bash
bash pam_audit_enhanced.sh
```

## Enhancement Option 2 — `tests_custom`

A native Lynis module that registers the custom test **`CUST-0100`** and reports
its findings through the standard Lynis functions (`Display`, `ReportWarning`,
`ReportSuggestion`, `LogText`). Because it is a real Lynis test, the results
appear in the console output, in `lynis.log` and in `lynis-report.dat` alongside
the built-in checks.

Install it into the Lynis include directory and run an audit:

```bash
sudo cp tests_custom /usr/share/lynis/include/tests_custom
sudo chmod 640 /usr/share/lynis/include/tests_custom
sudo lynis audit system --quick
```

Remove it with:

```bash
sudo rm /usr/share/lynis/include/tests_custom
```

## Requirements

- Linux host with PAM (`/etc/pam.d` present)
- Lynis 3.x for Option 2
- Bash for Option 1, POSIX `sh` for Option 2

## Author

Shriansh Tripathi

## Reference

Both enhancements extend the base PAM audit script (reference script 1 in the
accompanying blog post).
