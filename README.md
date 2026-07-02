# Codex Reset Query

This repository publishes a reusable Codex skill for querying ChatGPT rate-limit reset credits without exposing local credentials.

## Contents

- `skills/rate-limit-reset-credits/SKILL.md`
- `skills/rate-limit-reset-credits/scripts/get-rate-limit-reset-credits.ps1`

## Safety

The script reads the access token from the local machine at `~/.codex/auth.json` and never stores it in this repository.

This repository excludes:

- `.env`
- `sessions/`

## Usage

```powershell
& "$HOME\.codex\skills\rate-limit-reset-credits\scripts\get-rate-limit-reset-credits.ps1"
```
