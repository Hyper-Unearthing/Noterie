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

# Create empty notes.txt
touch "$INSTALL_DIR/notes.txt"

# Detect shell and add to PATH
if [ -n "$ZSH_VERSION" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    RC_FILE="$HOME/.bashrc"
else
    RC_FILE="$HOME/.profile"
fi

# Add to PATH if not already present
if ! grep -q 'export PATH="$PATH:$HOME/.noterie"' "$RC_FILE" 2>/dev/null; then
    echo "" >> "$RC_FILE"
    echo "# Noterie - AI-powered note-taking" >> "$RC_FILE"
    echo 'export PATH="$PATH:$HOME/.noterie"' >> "$RC_FILE"
    echo "Added noterie to PATH in $RC_FILE"
else
    echo "Noterie already in PATH"
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
echo "To start using noterie, run:"
echo "  source $RC_FILE"
echo ""
echo "Quick start:"
echo "  noterie          # Open editor to add a note"
echo "  noterie -n \"...\"  # Quick note"
echo "  noterie -q \"...\"  # Query your notes"
echo ""
echo "Your notes are stored in: ~/.noterie/notes.txt"
echo "Customize the AI behavior: ~/.noterie/system-prompt.txt"
echo "Customize the strategy: ~/.noterie/strategy.md"
echo ""
echo "GitHub: https://github.com/Hyper-Unearthing/Noterie"
