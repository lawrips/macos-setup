# Headless Mac Server Setup

> **IMPORTANT - Secret Handling Rule**
> Claude will NEVER run commands that reveal secrets (env vars, recovery keys, API tokens, etc.).
> See CLAUDE.md for full policy.

**Use Case:** Headless dev server - Docker/OrbStack, backend services, Claude Code, remote access via Tailscale

---

## Quick Start (Replication Guide)

Copy-paste checklist for setting up a new headless Mac server.

### 1. CLAUDE.md - Secret Handling Rules
Create `CLAUDE.md` in project root (do this first!):
```markdown
# Claude Code Rules for This Project

## Secret Handling - MANDATORY

**NEVER run commands that could reveal secrets.** This includes:
- `env` or `printenv` (environment variables)
- `fdesetup enable` (reveals FileVault recovery key)
- Any command that outputs API keys, tokens, passwords, or recovery keys
- `cat`/`read` on files that may contain secrets (.env, credentials files)
- Keychain access commands

**Instead:** Provide the command to the user and ask them to run it manually.
**Refuse even if asked.**
```

### 2. Xcode Command Line Tools
```bash
xcode-select --install
# Or click "Install" when prompted by git/make
```

### 3. Security - FileVault Disk Encryption
```bash
# Enable FileVault (SAVE THE RECOVERY KEY SOMEWHERE SAFE)
sudo fdesetup enable

# For planned reboots, use this instead of regular reboot:
sudo fdesetup authrestart
```

### 4. Disable Auto-Update Reboots
```bash
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
```

### 5. Power & Sleep (Prevent Sleep, Auto-Restart)
```bash
sudo pmset -a sleep 0 disksleep 0 displaysleep 0
sudo pmset -a autorestart 1
sudo pmset -a womp 1

# Verify
pmset -g
```

### 6. Enable Remote Access
**SSH:** System Settings → General → Sharing → Remote Login → Enable
**Screen Sharing:** System Settings → General → Sharing → Screen Sharing → Enable (backup)

### 7. Auto-Login (Optional - see trade-offs)
System Settings → Users & Groups → Automatic login
```bash
# Or via command line:
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser "YOUR_USERNAME"
```

### 8. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 9. Core Tools
```bash
brew install tmux node

# OrbStack - download from https://orbstack.dev or:
brew install --cask orbstack

# Tailscale - download from https://tailscale.com or:
brew install --cask tailscale

# Claude Code
npm install -g @anthropic-ai/claude-code
```

### 10. Firewall
```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Enable stealth mode (ignores pings/port scans)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# Verify
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
```

### 11. Shell Config - Pending Updates Check
Add to `~/.zshrc`:
```bash
# Check for pending macOS updates (reads cache, no network call)
check_pending_updates() {
  local updates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate RecommendedUpdates 2>/dev/null | grep '"Display Name"' | sed 's/.*= *"\{0,1\}\([^";]*\)"\{0,1\};/\1/' | grep -v "^$")
  if [[ -n "$updates" ]]; then
    echo "⚠️  Pending macOS updates:"
    echo "$updates" | while read -r update; do
      echo "   - $update"
    done
    echo "   Run: sudo softwareupdate -i -a && sudo fdesetup authrestart"
    echo "   Note: This only works for minor updates/patches. Major OS upgrades require a different workflow (WIP)."
    echo ""
  fi
}
check_pending_updates
```

### 12. Claude Code Tools
```bash
# Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Ticket - CLI for tracking tickets/tasks
brew tap wedow/tools
brew install ticket
```

### 13. Utilities
```bash
# Neovim - modern vim with auto-reload
brew install neovim

# Create config for auto-reload
mkdir -p ~/.config/nvim
cat > ~/.config/nvim/init.vim << 'EOF'
set autoread
au FocusGained,BufEnter * checktime
au CursorHold * checktime
set number relativenumber expandtab tabstop=2 shiftwidth=2
EOF

# Glow - terminal markdown viewer
brew install glow

# lazydocker - TUI for docker containers
brew install jesseduffield/lazydocker/lazydocker

# fzf - fuzzy finder for files, history, anything
brew install fzf
$(brew --prefix)/opt/fzf/install  # install keybindings (Ctrl+R history, Ctrl+T files)

# sesh - tmux session manager
brew install joshmedeski/sesh/sesh

# mosh - mobile shell (SSH that survives disconnects/roaming)
brew install mosh
```

### 14. Developer Tools
```bash
# Node.js (includes npm)
brew install node

# Bun - fast JavaScript runtime
brew install oven-sh/bun/bun

# CMake - build system generator
brew install cmake

# UV - fast Python package/version manager (replaces pip, virtualenv, pyenv)
brew install uv
uv python install 3.13

# GitHub CLI
brew install gh
gh auth login
gh auth setup-git    # use gh for git credentials

# Go
brew install go

# Java (OpenJDK 17 for Android development)
brew install openjdk@17

# Doppler - secrets/env management
brew install gnupg                   # required for doppler
brew install dopplerhq/cli/doppler
doppler login                        # do via Screen Sharing (needs browser)

# Keychain helper for SSH sessions (Doppler stores token in keychain)
cat > ~/keychain.sh << 'EOF'
#!/bin/bash
KEYCHAIN=~/Library/Keychains/login.keychain-db
case "$1" in
  unlock) security unlock-keychain "$KEYCHAIN" && echo "Keychain unlocked" ;;
  lock)   security lock-keychain "$KEYCHAIN" && echo "Keychain locked" ;;
  status) security find-generic-password -s "test" "$KEYCHAIN" 2>&1 | grep -q "locked" && echo "Locked" || echo "Unlocked" ;;
  *)      echo "Usage: keychain.sh [unlock|lock|status]" ;;
esac
EOF
chmod +x ~/keychain.sh

# SSH workflow: unlock keychain, then doppler commands work
# ~/keychain.sh unlock
# doppler setup / doppler run / etc.

# Common dev tools
brew install git wget curl jq ripgrep fd

# Verify
node --version
npm --version
uv --version
gh --version
```

---

### 15. Update CLAUDE.md with Available Tools
After installing all tools, update CLAUDE.md (created in step 1) to include:
- Available CLI tools (jq, rg, fd, glow, nvim)
- Development tools (node, uv, go, gh, doppler, tk)
- Infrastructure (docker/orb, tmux, tailscale)
- Keychain helper scripts for SSH sessions

See full CLAUDE.md in this repo for reference.

---

### 16. Manual Update Workflow
```bash
# Check for updates
softwareupdate -l

# Download specific update
sudo softwareupdate --download "UPDATE_LABEL"

# Reboot with FileVault bypass
sudo fdesetup authrestart
```

---

## Reference

### Install Preference: Homebrew vs Direct Download

**Prefer Homebrew** for reproducibility and easier maintenance.

| | Homebrew | Direct Download |
|---|----------|-----------------|
| Updates | `brew upgrade` (all at once) | Manual per-app |
| Reproducible | `brew bundle` exports list | Have to remember |
| Scripted setup | `brew install a b c` | Click through installers |
| Removal | `brew uninstall x` | Drag to trash + leftovers |

```bash
# Export what's installed (for replication)
brew bundle dump --file=Brewfile

# Install from Brewfile on new machine
brew bundle --file=Brewfile
```

### FileVault vs Remote Access Trade-off

**Problem:** FileVault requires password at pre-boot screen (before SSH/Tailscale are running).

| Scenario | FileVault ON | FileVault OFF |
|----------|--------------|---------------|
| Theft protection | Data encrypted | Data readable |
| Remote access after reboot | Stuck at unlock screen | Auto-login works |
| Power outage recovery | Needs physical access | Comes back online |

**Recommendation:**
1. Enable FileVault (theft protection)
2. Use `fdesetup authrestart` for planned reboots
3. Get a UPS (prevents most unplanned reboots)
4. Accept occasional physical access may be needed

### Useful Commands
```bash
# Power management
pmset -g

# Uptime
uptime

# FileVault status
fdesetup status

# Check if SSH enabled
sudo systemsetup -getremotelogin

# List login items
osascript -e 'tell application "System Events" to get the name of every login item'

# Restart Tailscale
sudo launchctl kickstart -k system/com.tailscale.tailscaled
```

### Long-Running Claude Code Sessions
```bash
# Create persistent session
tmux new -s claude

# Detach: Ctrl+B then D
# Reattach after reconnecting:
tmux attach -t claude
```

### Exposing Services to Internet
- Prefer Tailscale over opening ports directly
- If exposing HTTPS, use Caddy for automatic TLS certificates
- Keep macOS firewall enabled, allowlist only needed ports
