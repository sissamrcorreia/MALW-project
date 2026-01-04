# VeilVault-WikiWorm

![Python](https://img.shields.io/badge/Python-3.10%2B-blue?style=for-the-badge&logo=python)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue?style=for-the-badge&logo=powershell)
![Microsoft Office](https://img.shields.io/badge/Microsoft_Office-365-orange?style=for-the-badge&logo=microsoft-office)
![XWiki](https://img.shields.io/badge/XWiki-15.0%2B-lightblue?style=for-the-badge&logo=wiki)
![GitLab](https://img.shields.io/badge/GitLab_CI-purple?style=for-the-badge&logo=gitlab)

Project of Malware.

> **Educational proof-of-concept** demonstrating a multi-stage attack chain that pivots from a malicious Word file to an internal XWiki, spreads via CI/CD webhooks and finally encrypts legal documents.

**WARNING**: This repository contains **research-only** code.
Do **not** deploy on production systems or against targets without explicit authorization.
All activity must comply with applicable laws and ethical guidelines.

---

## 💡 Story (high-level)

1. **Phishing** – Word attachment exploiting (CVE-2025-47957)
2. **Pivot** – PowerShell dropper → XWiki RCE (CVE-2025-24893)
3. **Worm** – XWiki pages + webhooks push polymorphic payloads into GitLab CI
4. **Encryption** – Go binary
5. **Ransom** – Monero demand + automated key delivery

---

## 📁 Repository layout

```attacker/exploit/```      → PoC modules for the two CVEs

```attacker/ransomware/```          → Files for the ransomware

```attacker/worm/```          → Worm and propagation scripts

```docs/```          → Attack flow and mitigation notes

```xwiki/```          → Files related to XWiki

---

## 👥 Authors

Team 2

Anna Melkumyan Canosa; Andrea Victoria Piñón Rattia; Cecília Maria Rodrigues Correia; Oriol Ramos Puig
