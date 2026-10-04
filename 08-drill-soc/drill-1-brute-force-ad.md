# Drill 1 — Brute Force against Active Directory (Blue Team)

**Date:** 2026-10-04 · **Lab:** Nexora Security Lab (isolated, authorized)
**Stack:** Wazuh + Sysmon SIEM · Windows Server 2025 DC (SRV-DC01 / nexora.local) · Kali attacker

## Scenario
Simulated a password brute-force / guessing attack against the domain account
`joao.souza`, then triaged it as a SOC analyst.

## Attack (authorized lab)
```
netexec smb 192.168.10.10 -u joao.souza -p senhas.txt
```

## Triage card
- **Event ID:** Windows Security 4776 (NTLM Credential Validation, Audit Failure);
  related 4625 (failed logon) and 4740 (account lockout)
- **Severity:** High
- **DC:** SRV-DC01.nexora.local · **Source workstation:** KALI · **Target user:** joao.souza
- **Evidence:** burst of 4776 "Audit Failure" in a short window; Error Code
  `0xC000006A` = STATUS_WRONG_PASSWORD (many wrong passwords, single account);
  `4740` fired → account was LOCKED OUT.
- **Verdict:** TP (True Positive) — brute-force password guessing from a single source.
- **Compromise?** No — all attempts failed; account locked before any success.
- **Containment:** account-lockout GPO contained it automatically. Confirm source host,
  unlock after validation, review why the account was targeted, consider blocking the source.
- **MITRE ATT&CK:** T1110.001 — Brute Force: Password Guessing

## Troubleshooting — a real detection blind spot
The expected alert did not show up in Wazuh. Walking the pipeline
(attack → DC logs → agent → manager → dashboard):

1. The attack reached the DC (SMB fingerprint succeeded; `ping` ok, port 445 open).
2. The DC **did** log the failures — as **4776 (NTLM)**, not 4625, because netexec
   authenticates via NTLM straight to the DC.
3. These events were **not** reaching Wazuh. Filtering `agent.name: SRV-DC01` showed
   only `Microsoft-Windows-Sysmon/Operational` — the **Security** channel was missing.
4. **Root cause:** the agent's `ossec.conf` on the DC was collecting Sysmon but **not**
   the Windows **Security** event channel.

**Fix** (`C:\Program Files (x86)\ossec-agent\ossec.conf`):

```xml
<localfile>
  <location>Security</location>
  <log_format>eventchannel</log_format>
</localfile>
```

Restarted the agent (`Restart-Service WazuhSvc`), re-ran the attack → 4776 arrived in Wazuh.

## Lessons learned
- For NTLM auth against a DC the key artifact is **4776** (with error code), not just 4625.
  Kerberos pre-auth failures = **4771**; account lockout = **4740**.
- `0xC000006A` = wrong password. One account + many passwords = **guessing** (T1110.001);
  many accounts + one password = **spraying** (T1110.003).
- **Detection content must match the telemetry you actually ingest** — a rule keyed on
  4625/4740 never fires if the Security channel isn't collected.
- Always validate log sources: confirm every critical channel reaches the SIEM.
