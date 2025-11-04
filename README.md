# VeilVault-WikiWorm

Project of Malware.

> **Educational proof-of-concept** demonstrating a multi-stage attack chain that pivots from a malicious Excel file to an internal XWiki, spreads via CI/CD webhooks, and finally encrypts legal documents.

**WARNING**: This repository contains **research-only** code.
Do **not** deploy on production systems or against targets without explicit authorization.
All activity must comply with applicable laws and ethical guidelines.

---

## Story (high-level)

1. **Phishing** – Excel attachment exploiting (CVE-2025-47957)
2. **Pivot** – PowerShell dropper → XWiki RCE (CVE-2025-24893)
3. **Worm** – Wiki pages + webhooks push polymorphic payloads into GitLab CI
4. **Encryption** – Go binary (`shadowvault.exe`) locks `\\fileserver\legal\` with ChaCha20-Poly1305
5. **Ransom** – Monero demand + automated key delivery via Telegram bot

---

## Repository layout - to be updated

```docs/```          → Diagrams, attack flow, mitigation notes

```exploits/```      → PoC modules for the two CVEs

```payload/```      → Dropper, encryptor, webshell source

```scripts/```      → Automation helpers

```tests/```       → Future test harness

---

## Authors

Team 2

Anna Melkumyan Canosa; Andrea Victoria Piñón Rattia; Cecília Maria Rodrigues Correia; Oriol Ramos Puig
