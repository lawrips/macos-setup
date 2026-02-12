#!/bin/bash
# Menu-driven macOS major upgrade installer
set -euo pipefail

echo "Fetching available macOS installers..."
echo ""

# List full installers
output=$(softwareupdate --list-full-installers 2>&1) || true

# Parse versions and titles
versions=()
titles=()
while IFS= read -r line; do
  if [[ "$line" == *"Title:"* ]]; then
    title=$(echo "$line" | sed 's/.*Title: \([^,]*\),.*/\1/')
    version=$(echo "$line" | sed 's/.*Version: \([^,]*\),.*/\1/')
    titles+=("$title $version")
    versions+=("$version")
  fi
done <<< "$output"

if [[ ${#versions[@]} -eq 0 ]]; then
  echo "No macOS installers available."
  exit 0
fi

# Show current version
current=$(sw_vers -productVersion)
echo "Current macOS version: $current"
echo ""

# Display menu
echo "Available macOS versions:"
echo ""
for i in "${!titles[@]}"; do
  echo "  $((i + 1))) ${titles[$i]}"
done
echo ""
echo "  q) Quit"
echo ""

read -rp "Selection: " choice

if [[ "$choice" == "q" ]]; then
  exit 0
elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#versions[@]} )); then
  selected_version="${versions[$((choice - 1))]}"
  selected_title="${titles[$((choice - 1))]}"
else
  echo "Invalid selection."
  exit 1
fi

# Confirm download
echo ""
echo "Will download: $selected_title"
echo "This may take a while (several GB)."
echo ""
read -rp "Proceed? (y/n) " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

# Download full installer
echo ""
echo "Downloading installer..."
sudo softwareupdate --fetch-full-installer --full-installer-version "$selected_version"

# Find the installer app
installer=$(ls -d /Applications/Install\ macOS*.app 2>/dev/null | head -1)
if [[ -z "$installer" ]]; then
  echo "Error: Could not find installer in /Applications."
  exit 1
fi

echo ""
echo "Installer ready: $installer"
echo ""
echo "This will start the macOS upgrade and reboot the machine."
echo "You will lose SSH access during the upgrade."
echo "After upgrade, SSH into the FileVault pre-boot screen to unlock (Ethernet required)."
echo ""
read -rp "Start upgrade now? (y/n) " start
if [[ "$start" != "y" ]]; then
  echo "Installer downloaded. Run manually when ready:"
  echo "  sudo \"$installer/Contents/Resources/startosinstall\" --agreetolicense --forcequitapps --nointeraction --passprompt"
  exit 0
fi

# Run the installer (retry on auth failure)
while true; do
  if sudo "$installer/Contents/Resources/startosinstall" --agreetolicense --forcequitapps --nointeraction --passprompt; then
    break
  fi
  echo ""
  read -rp "Installation failed (wrong password?). Retry? (y/n) " retry
  if [[ "$retry" != "y" ]]; then
    echo "Cancelled."
    exit 1
  fi
done
