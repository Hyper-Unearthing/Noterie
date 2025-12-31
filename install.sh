#!/bin/bash

# Noterie Installer
# Installs noterie to ~/.noterie and adds it to PATH

set -e

INSTALL_DIR="$HOME/.noterie"
REPO_BASE="https://raw.githubusercontent.com/Hyper-Unearthing/Noterie/main"

echo "Installing Noterie..."
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download files from GitHub
echo "Downloading files from GitHub..."
curl -fsSL "$REPO_BASE/noterie" -o "$INSTALL_DIR/noterie"
curl -fsSL "$REPO_BASE/system-prompt.txt" -o "$INSTALL_DIR/system-prompt.txt"
curl -fsSL "$REPO_BASE/strategy.md" -o "$INSTALL_DIR/strategy.md"

# Make noterie executable
chmod +x "$INSTALL_DIR/noterie"

# Prompt for notes directory
echo ""
echo "Where would you like to store your notes?"
echo "(Press Enter for default: $HOME/notes)"
read -r NOTES_PATH

# Use default if empty
if [ -z "$NOTES_PATH" ]; then
    NOTES_PATH="$HOME/notes"
fi

# Convert ~ to $HOME
NOTES_PATH="${NOTES_PATH/#\~/$HOME}"

# Convert relative to absolute path
if [[ "$NOTES_PATH" != /* ]]; then
    # Get absolute path
    NOTES_PATH="$(cd "$(dirname "$NOTES_PATH")" 2>/dev/null && pwd)/$(basename "$NOTES_PATH")"
    # If cd failed, use current directory
    if [ $? -ne 0 ]; then
        NOTES_PATH="$(pwd)/$NOTES_PATH"
    fi
fi

# Detect shell and add to PATH
CURRENT_SHELL="${SHELL:-/bin/bash}"
case "$CURRENT_SHELL" in
    */zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    */bash)
        RC_FILE="$HOME/.bashrc"
        ;;
    *)
        RC_FILE="$HOME/.bashrc"
        ;;
esac

# Add to PATH if not already present
if ! grep -q 'export PATH="$PATH:$HOME/.noterie"' "$RC_FILE" 2>/dev/null; then
    echo "" >> "$RC_FILE"
    echo "# Noterie - AI-powered note-taking" >> "$RC_FILE"
    echo 'export PATH="$PATH:$HOME/.noterie"' >> "$RC_FILE"
    echo "export NOTERIE_DIR=\"$NOTES_PATH\"" >> "$RC_FILE"
    echo "Added noterie to PATH in $RC_FILE"
else
    # PATH already exists, just add/update NOTERIE_DIR
    if ! grep -q 'export NOTERIE_DIR=' "$RC_FILE" 2>/dev/null; then
        echo "export NOTERIE_DIR=\"$NOTES_PATH\"" >> "$RC_FILE"
    fi
    echo "Noterie already in PATH, updated NOTERIE_DIR"
fi

# Check if opencode is installed
if ! command -v opencode &> /dev/null; then
    echo ""
    echo "⚠️  Warning: opencode not found"
    echo "Please install OpenCode from: https://opencode.ai"
    echo ""
fi

# Success message
echo ""
echo "✓ Noterie installed successfully to ~/.noterie"
echo ""
echo "Your notes directory: $NOTES_PATH"
echo ""
echo "To start using noterie, run:"
echo "  source $RC_FILE"
echo ""
echo "Quick start:"
echo "  noterie          # Open editor to add a note"
echo "  noterie -n \"...\"  # Quick note"
echo "  noterie -q \"...\"  # Query your notes"
echo ""
echo "Customize AI: ~/.noterie/system-prompt.txt"
echo "Strategy: ~/.noterie/strategy.md"
echo ""
echo "GitHub: https://github.com/Hyper-Unearthing/Noterie"
