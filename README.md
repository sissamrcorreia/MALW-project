# VeilVault-WikiWorm

Project of Malware.

> **Educational proof-of-concept** demonstrating a multi-stage attack chain that pivots from a malicious Word file to an internal XWiki, spreads via CI/CD webhooks and finally encrypts legal documents.

**WARNING**: This repository contains **research-only** code.
Do **not** deploy on production systems or against targets without explicit authorization.
All activity must comply with applicable laws and ethical guidelines.

---

## Story (high-level)

1. **Phishing** – Word attachment exploiting (CVE-2025-47957)
2. **Pivot** – PowerShell dropper → XWiki RCE (CVE-2025-24893)
3. **Worm** – XWiki pages + webhooks push polymorphic payloads into GitLab CI
4. **Encryption** – Go binary
5. **Ransom** – Monero demand + automated key delivery

---

## Repository layout

```attacker/exploit/```      → PoC modules for the two CVEs

```attacker/ransomware/```          → Files for the ransomware

```attacker/worm/```          → Worm and propagation scripts

```docs/```          → Attack flow and mitigation notes

```xwiki/```          → Files related to XWiki

---

## Authors

Team 2

Anna Melkumyan Canosa; Andrea Victoria Piñón Rattia; Cecília Maria Rodrigues Correia; Oriol Ramos Puig
