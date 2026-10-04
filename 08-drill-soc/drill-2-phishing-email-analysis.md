# Drill 2 — Phishing Email Header Analysis (Blue Team)

**Date:** 2026-10-04 · **Lab:** Nexora Security Lab (training sample, benign)
**Type:** Credential phishing (fake Microsoft 365 login) reported by a user

## Scenario
A user forwarded a suspicious email. Triaged it as a SOC analyst: inspected the
headers, authentication results and the embedded link, extracted IOCs and decided
on containment.

## Evidence
- **Typosquatted sender domain:** `micros0ft-support[.]com` (zero instead of the letter "o")
- **Authentication failed:** SPF=fail (sender IP 185.220.101.47), DKIM=none,
  DMARC=fail (p=reject)
- **Header mismatch:** `From`, `Reply-To` and `Return-Path` are three different domains
  - From: `security@micros0ft-support[.]com`
  - Reply-To: `no-reply@secure-mailverify[.]ru`
  - Return-Path: `bounce@mailgun-send[.]net`
- **Social engineering lure:** urgency + threat ("password expires in 2 hours",
  "permanent account suspension")
- **Credential-harvesting link:** `hxxps://micros0ft-verify[.]ru/login?user=joao.souza`

## IOCs
- Sender IP: `185.220.101.47`
- Domains: `micros0ft-support[.]com`, `secure-mailverify[.]ru`, `micros0ft-verify[.]ru`
- URL: `hxxps://micros0ft-verify[.]ru/login`

## Verdict
**TP (True Positive) — credential phishing.** This is a fake login page designed to
steal the user's Microsoft 365 password (not malware delivery).

## Compromise check (user-side — critical)
- Verify whether the user **clicked the link or submitted credentials**.
- If yes: **reset the password** and **revoke active sessions/tokens** immediately.

## Containment / recommendation
- Quarantine/delete the email from all mailboxes; **search the campaign tenant-wide**
  (phishing is rarely sent to a single user).
- Block the sender domains, the URL and the IP at the mail gateway / firewall / proxy.
- Report the sender, add the IOCs to the blocklist, send a user-awareness note.

## Lessons learned
- The three address headers (`From` / `Reply-To` / `Return-Path`) pointing to different
  domains is a strong spoofing indicator.
- `DMARC p=reject` means the legitimate domain owner itself asks receivers to reject
  mail that fails authentication — a high-confidence signal.
- Credential phishing ≠ malware: the goal is harvesting the password, so containment
  must include a password reset / session revocation if the user interacted.

## MITRE ATT&CK
T1566.002 — Phishing: Spearphishing Link
