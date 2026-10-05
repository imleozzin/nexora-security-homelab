# Drill 2 - Password Spraying

**Date:** 2026-10-04 . **Lab:** Nexora Security Lab

## Scenario
Simulated a Password Spraying / guessing attack against the domain account targetUserName, then triaged as a SOC Analyst.

## Attack
```
netexec smb 192.168.10.10 -u user.txt -p 'Nexora@2026'
```

## Triage card: 
- **Event ID:** Windows Security 4625
- **Severity:** Low
- **Host:** SRV-DC01
- **IP:** 192.168.99.50<br>
- **Target User:** maria.silva / joao.souza / administrator <br>
- **Evidence:** same source IP (192.168.99.50), many different target users, ~1 attempt each, no 4740 lockout".
- **Verdict:** TP (True Positive) - Password Spraying - Password guessing by multiple users attempting to log in without locking their accounts.
- **Compromise?** No - all attemps failed.
- **Containment:** Confirm source host, review why the account was targeted, consider blocking the source, check if any attempt succeeded (4624 / 0x0)" e "enforce MFA + strong password policy.
- **MITRE ATT&CK:** T1110.003 - Password Spraying 
