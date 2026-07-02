---
name: rate-limit-reset-credits
description: Safely query ChatGPT rate-limit reset credits using the local Codex credential in `~/.codex/auth.json`, then summarize `available_count` and each credit's `status`, `title`, `granted_at`, and `expires_at`. Use when the user asks to inspect reset credits, check whether a full reset is available, verify raw UTC versus local-time conversions, or troubleshoot a `401` that may mean the bearer token is expired or the Authorization header is wrong.
---

# Rate Limit Reset Credits

Use the bundled PowerShell script instead of rewriting an ad hoc fetch each time.

## Workflow

1. Read `~/.codex/auth.json` and extract only `tokens.access_token`.
2. Send `GET https://chatgpt.com/backend-api/wham/rate-limit-reset-credits` with `Authorization: Bearer <access_token>`.
3. Never print `access_token`, `refresh_token`, cookies, or full unique IDs.
4. Summarize only:
   - `available_count`
   - for each credit: `status`, `title`, `granted_at`, `expires_at`
5. Treat timestamps ending in `Z` as UTC, then convert them to the local machine timezone for display.
6. If the status code is `401`, report that the credential is expired or the Authorization header is missing or incorrect.

## Script

Run:

```powershell
& "$HOME\.codex\skills\rate-limit-reset-credits\scripts\get-rate-limit-reset-credits.ps1"
```

The script prints compact JSON that already follows the reporting constraints.

## Reporting

Default to reporting only the local-time summary.

If the user questions the conversion, include both:
- raw UTC string from the API
- converted local-time value

Do not echo the raw response body unless the user explicitly asks for it and it does not expose secrets.
