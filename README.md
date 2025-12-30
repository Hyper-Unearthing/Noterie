# Noterie

AI-powered note-taking CLI that uses OpenCode to manage your notes intelligently.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Hyper-Unearthing/Noterie/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

## Usage

### Add a note (interactive editor)
```bash
noterie
```
Opens your `$EDITOR` (or nano by default) to write a note. When you save and close, the note is appended to the top of your notes file.

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
- Notes are stored in `~/.noterie/notes.txt`
- Each note gets a timestamp when added: `[YYYY-MM-DD HH:MM]`
- Your notes remain in plain text, searchable with CTRL+F
- The AI follows a customizable note-taking strategy

## Customization

You can customize Noterie by editing files in `~/.noterie/`:

- **`system-prompt.txt`** - Instructions for the AI assistant
- **`strategy.md`** - The note-taking strategy/philosophy
- **`notes.txt`** - Your actual notes (managed by noterie commands)

## Requirements

- [OpenCode](https://opencode.ai) must be installed
- Bash or Zsh shell

## Uninstallation

```bash
rm -rf ~/.noterie
# Remove the PATH export line from your ~/.zshrc or ~/.bashrc
```

## License

MIT
