# Headless Mac Server Setup

A comprehensive guide for setting up a Mac as a headless development server with remote access, Docker, and modern dev tools.

## Use Case

- Headless server (99% remote access via SSH)
- Docker containers via OrbStack
- Backend services (Whisper, etc.)
- Claude Code long-running terminals
- Remote access via Tailscale
- Occasional HTTPS ports exposed to internet

## What's Included

| File | Purpose |
|------|---------|
| `setup.md` | Complete setup guide with copy-paste commands |
| `install-log.md` | Create your own to track setup progress (gitignored) |
| `CLAUDE.md` | Rules and available tools for Claude Code |
| `Brewfile` | Homebrew packages for one-command install |

## Quick Start

```bash
# Clone this repo
git clone https://github.com/lawrips/macos-setup.git
cd macos-setup

# Follow the guide
open setup.md

# Or install all Homebrew packages at once
brew bundle --file=Brewfile
```

## Key Features

### Security + Remote Access Balance
- FileVault disk encryption (theft protection)
- `fdesetup authrestart` for planned reboots (bypasses FileVault unlock screen)
- Automatic update reboots disabled (prevents getting locked out)

### 24/7 Operation
- Sleep disabled, auto-restart after power failure
- Wake on LAN enabled
- SSH + Screen Sharing for remote access
- Tailscale for secure access from anywhere

### Modern Dev Tools
- **uv** instead of pip/pyenv (10-100x faster)
- **OrbStack** instead of Docker Desktop (lighter)
- **Neovim** with auto-reload
- **Doppler** for secrets management

## Files Overview

### setup.md
Step-by-step guide covering:
1. CLAUDE.md secret handling rules
2. Xcode Command Line Tools
3. FileVault encryption
4. Power/sleep settings
5. Remote access (SSH, Screen Sharing, Tailscale)
6. Homebrew + core tools
7. Developer tools (Node, Python/uv, Go, etc.)
8. Firewall configuration

### install-log.md
Create your own `install-log.md` to track progress as you go through the setup. It's gitignored so it won't be committed.

### CLAUDE.md
Instructions for Claude Code including:
- Secret handling rules (never reveal tokens, keys, etc.)
- Available CLI tools and their usage
- Helper scripts (keychain unlock for SSH sessions)

### Brewfile
All Homebrew packages for easy replication:
```bash
brew bundle --file=Brewfile
```

## SSH Workflow

```bash
# Connect via Tailscale
ssh user@hostname

# Start/attach tmux session
tmux new-session -A -s main

# Unlock keychain (for Doppler)
~/keychain.sh unlock

# Work...
```

## License

MIT - Use however you like.
