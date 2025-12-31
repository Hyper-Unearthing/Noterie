# Noterie

AI-powered note-taking CLI that uses OpenCode to manage your notes intelligently.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Hyper-Unearthing/Noterie/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

During installation, you'll be prompted to specify where you want to store your notes (default: `$HOME/notes`).

## Usage

### Add a note (interactive editor)
```bash
noterie
```
Opens your `$EDITOR` (or vim by default) to write a note. When you save and close, the note is appended to the top of your notes file.

### Quick note
```bash
noterie -n "Remember to review Q4 metrics tomorrow"
```
Adds a note directly without opening an editor.

### Query your notes
```bash
noterie -q "What todos do I have?"
```
Ask questions about your notes. The AI will search through your notes and provide answers.

## How it works

Noterie uses OpenCode (specifically Grok Code Fast) to intelligently manage your notes:
- Notes are stored in your configured directory (`$NOTERIE_DIR`)
- The AI organizes files based on your customizable strategy
- Your notes remain in plain text and searchable
- Query across all your notes - the AI searches the entire directory

## Customization

You can customize Noterie by editing files in `~/.noterie/`:

- **`system-prompt.txt`** - Instructions for the AI assistant
- **`strategy.md`** - The note-taking strategy/philosophy

Your notes are stored in `$NOTERIE_DIR` (set during installation).

**To change your notes directory:**
```bash
export NOTERIE_DIR="/new/path/to/notes"
# Add this to your ~/.zshrc or ~/.bashrc to make it permanent
```

## Requirements

- [OpenCode](https://opencode.ai) must be installed
- Bash or Zsh shell

## Uninstallation

```bash
# Your notes in $NOTERIE_DIR are safe and won't be deleted

rm -rf ~/.noterie
# Remove the PATH and NOTERIE_DIR export lines from your ~/.zshrc or ~/.bashrc
```

## Troubleshooting

### Command not found
```bash
# Make sure PATH is updated
source ~/.zshrc  # or source ~/.bashrc

# Verify noterie is in PATH
which noterie

# Should output: ~/.noterie/noterie
```

### OpenCode errors
```bash
# Check if opencode is installed
which opencode

# Test opencode directly
opencode run -m opencode/grok-code "hello"
```

### Notes not saving
```bash
# Check if NOTERIE_DIR is set
echo $NOTERIE_DIR

# Check directory permissions
ls -la $NOTERIE_DIR

# Verify directory exists
mkdir -p $NOTERIE_DIR
```

### Editor not opening
```bash
# Check EDITOR variable
echo $EDITOR

# Set it if empty
export EDITOR=vim
```


## License

MIT
