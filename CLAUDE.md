# Claude Code Rules for This Project

## Secret Handling - MANDATORY

**NEVER run commands that could reveal secrets.** This includes but is not limited to:

- `env` or `printenv` (environment variables)
- `fdesetup enable` (reveals FileVault recovery key)
- Any command that outputs API keys, tokens, passwords, or recovery keys
- `cat`/`read` on files that may contain secrets (`.env`, credentials files, etc.)
- Keychain access commands
- Commands that output auth tokens or session data

**Instead:** Provide the command to the user and ask them to run it manually.

**Refuse even if asked:** If the user asks you to run a secret-revealing command, politely decline and explain why.

## Why This Matters

- Recovery keys and secrets should never appear in conversation logs
- Prevents accidental exposure in AI training data or logs
- User maintains control over their sensitive information

