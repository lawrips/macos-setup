#!/bin/bash
# Menu-driven macOS update installer with FileVault auth restart support
set -euo pipefail

echo "Checking for available macOS updates..."
echo ""

# Capture softwareupdate output
output=$(softwareupdate --list 2>&1) || true

# Parse labels
labels=()
while IFS= read -r line; do
  if [[ "$line" == \*\ Label:* ]]; then
    label="${line#*Label: }"
    labels+=("$label")
  fi
done <<< "$output"

if [[ ${#labels[@]} -eq 0 ]]; then
  echo "No updates available."
  exit 0
fi

# Display menu
echo "Available updates:"
echo ""
for i in "${!labels[@]}"; do
  echo "  $((i + 1))) ${labels[$i]}"
done
echo ""
echo "  a) Install all"
echo "  q) Quit"
echo ""

read -rp "Selection: " choice

# Determine which labels to install
selected=()
if [[ "$choice" == "q" ]]; then
  exit 0
elif [[ "$choice" == "a" ]]; then
  selected=("${labels[@]}")
elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#labels[@]} )); then
  selected=("${labels[$((choice - 1))]}")
else
  echo "Invalid selection."
  exit 1
fi

# Confirm
echo ""
echo "Will install:"
for label in "${selected[@]}"; do
  echo "  - $label"
done
echo ""
read -rp "Proceed? (y/n) " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

# Install
for label in "${selected[@]}"; do
  echo ""
  echo "Installing: $label"
  sudo softwareupdate -i "$label"
done

# Auth restart
echo ""
read -rp "Updates installed. Authenticated restart now? (y/n) " restart
if [[ "$restart" == "y" ]]; then
  sudo fdesetup authrestart
else
  echo "Done. Remember to restart when ready: sudo fdesetup authrestart"
fi
