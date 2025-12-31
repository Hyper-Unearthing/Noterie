# Noterie Architecture

## Overview

Noterie is a CLI tool that uses OpenCode (with Grok Code Fast model) to provide AI-powered note management following the append-and-review strategy.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User invokes noterie                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
              ┌─────────────────────┐
              │  Parse arguments    │
              │  (bash script)      │
              └─────────┬───────────┘
                        │
          ┌─────────────┼─────────────┐
          │             │             │
          ▼             ▼             ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  Mode 1 │   │  Mode 2 │   │  Mode 3 │
    │ Editor  │   │  -n     │   │  -q     │
    │ Opens   │   │ Quick   │   │ Query   │
    │ $EDITOR │   │ Note    │   │ Notes   │
    └────┬────┘   └────┬────┘   └────┬────┘
         │             │             │
         └─────────────┼─────────────┘
                       │
                       ▼
         ┌─────────────────────────────┐
         │  Build OpenCode Prompt      │
         │  - Read system-prompt.txt   │
         │  - Read strategy.md         │
         │  - Add mode instruction     │
         │  - Add user content         │
         └──────────┬──────────────────┘
                    │
                    ▼
         ┌─────────────────────────────┐
         │  Execute OpenCode           │
         │  opencode run -m            │
         │  opencode/grok-code         │
         │  "<multiline prompt>"       │
         └──────────┬──────────────────┘
                    │
                    ▼
         ┌─────────────────────────────┐
         │  OpenCode performs actions  │
         │  - Reads notes.txt          │
         │  - Edits notes.txt          │
         │  - Returns response         │
         └──────────┬──────────────────┘
                    │
                    ▼
         ┌─────────────────────────────┐
         │  Display output to user     │
         └─────────────────────────────┘
```

## Directory Structure

### Development Repository
```
/Users/seb/work/noterie/  (GitHub: Hyper-Unearthing/Noterie)
├── .git/                  # Git repository
├── .gitignore             # Excludes notes.txt, last_note
├── LICENSE                # MIT License
├── README.md              # User documentation
├── docs/                  # Architecture documentation
│   └── ARCHITECTURE.md
├── install.sh             # Installation script (executable)
├── noterie                # Main CLI script (executable)
├── strategy.md            # Default append-and-review strategy
└── system-prompt.txt      # OpenCode system prompt
```

### User Installation (`~/.noterie/`)
```
~/.noterie/
├── noterie                # Downloaded from GitHub (executable)
├── strategy.md            # Downloaded from GitHub (user can customize)
├── system-prompt.txt      # Downloaded from GitHub (user can customize)
├── notes.txt              # Created empty locally (user's notes)
└── last_note              # Temporary file (created/deleted as needed)
```

## Core Components

### 1. `noterie` - Main Bash Script

**Purpose**: CLI entry point that orchestrates all functionality

**Key Variables**:
```bash
SCRIPT_DIR              # Directory where noterie is installed
NOTES_FILE              # Path to notes.txt
LAST_NOTE               # Temporary file for editor mode
SYSTEM_PROMPT_FILE      # Path to system-prompt.txt
STRATEGY_FILE           # Path to strategy.md
MODEL                   # OpenCode model: opencode/grok-code
```

**Core Functions**:

| Function | Purpose |
|----------|---------|
| `check_dependencies()` | Verifies opencode is installed |
| `build_prompt(mode, content)` | Constructs full OpenCode prompt |
| `run_opencode(prompt)` | Executes OpenCode and returns output |
| `mode_editor()` | Mode 1: Opens editor, reads content |
| `mode_note(content)` | Mode 2: Quick note without editor |
| `mode_query(query)` | Mode 3: Query notes |
| `show_help()` | Displays usage information |
| `main()` | Entry point, argument parsing |

### 2. `system-prompt.txt` - OpenCode System Prompt

**Purpose**: Defines OpenCode's behavior and responsibilities

**Key Instructions**:
- Append notes to TOP of file with timestamp `[YYYY-MM-DD HH:MM]`
- Preserve user's exact wording
- Keep responses brief and actionable
- Use Read tool to read notes.txt
- Use Edit tool to modify notes.txt

### 3. `strategy.md` - Note-taking Strategy

**Purpose**: Defines the note-taking philosophy

**Key Concepts**:
- Single text file for all notes
- Append new notes to top
- Notes "sink" over time
- Review and rescue important notes
- Use CTRL+F for searching

**Customization**: Users can edit this file to match their preferred approach

### 4. `install.sh` - Installation Script

**Purpose**: Download and set up Noterie on user's system

**Process**:
1. Create `~/.noterie/` directory
2. Download files from GitHub:
   - `noterie`
   - `system-prompt.txt`
   - `strategy.md`
3. Make `noterie` executable
4. Create empty `notes.txt`
5. Detect shell (zsh/bash)
6. Add `~/.noterie` to PATH in shell rc file
7. Check if opencode is installed
8. Display success message

## Operating Modes

### Mode 1: Interactive Editor (`noterie`)

**Flow**:
1. Create/clear `last_note` file
2. Open `$EDITOR` (or nano) with `last_note`
3. Wait for user to save and close
4. Read contents of `last_note`
5. Check if empty → if yes, show "No note added" and exit
6. Build prompt with "append" instruction
7. Execute OpenCode
8. Display output
9. Delete `last_note`

**Prompt Structure**:
```
<system-prompt.txt content>

## Note-taking Strategy
<strategy.md content>

## User Request
The user has created a new note. Append it to the TOP of ~/.noterie/notes.txt
with a timestamp in the format [YYYY-MM-DD HH:MM].

## New Note Content
<contents from editor>

Please append this note and confirm it has been saved.
```

### Mode 2: Quick Note (`noterie -n "content"`)

**Flow**:
1. Parse note content from arguments
2. Check if empty → error if yes
3. Build prompt with "append" instruction
4. Execute OpenCode
5. Display output

**Same prompt structure as Mode 1**, but content comes from command line

### Mode 3: Query (`noterie -q "query"`)

**Flow**:
1. Parse query from arguments
2. Check if empty → error if yes
3. Build prompt with "query" instruction
4. Execute OpenCode
5. Display output

**Prompt Structure**:
```
<system-prompt.txt content>

## Note-taking Strategy
<strategy.md content>

## User Request
The user has a query about their notes. Read ~/.noterie/notes.txt and provide
a helpful, concise answer.

## Query
<user's query>
```

## OpenCode Integration

### Model
- **Provider**: OpenCode
- **Model**: `grok-code`
- **Hardcoded**: Yes (can be changed by editing the script)

### Execution
```bash
opencode run -m opencode/grok-code "<multiline prompt>"
```

### File Operations
OpenCode uses its built-in tools:
- **Read tool**: To read `notes.txt`
- **Edit tool**: To modify `notes.txt` (append to top)
- **Bash tool**: To get current timestamp

### Output
- Full OpenCode response is displayed to user
- Typical response for append: "Note saved."
- Typical response for query: Direct answer with relevant note citations

## Data Flow

### Append Note Flow
```
User input → noterie script → Build prompt → OpenCode
                                               ↓
User ← Display output ← Return response ← Edit notes.txt
                                               ↓
                                          Add timestamp
                                          Prepend to top
```

### Query Note Flow
```
User query → noterie script → Build prompt → OpenCode
                                               ↓
User ← Display output ← Return response ← Read notes.txt
                                               ↓
                                          Search content
                                          Find relevant notes
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| OpenCode not installed | Show error, exit with code 1 |
| `$EDITOR` not set | Default to `nano` |
| Empty editor content | Show "No note added", skip OpenCode |
| Empty `-n` argument | Show error and usage |
| Empty `-q` argument | Show error and usage |
| `notes.txt` doesn't exist | Create it automatically |
| Invalid argument | Show error and help text |

## File Paths

All file paths are **dynamic** based on where the script is installed:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

This ensures noterie works whether installed in:
- `~/.noterie/` (production)
- `/Users/seb/work/noterie/` (development)
- Any other location

## Security Considerations

- **No API keys required**: Uses OpenCode which handles authentication
- **Local file storage**: All notes stored locally in `~/.noterie/notes.txt`
- **No network requests**: Except to OpenCode API (via opencode CLI)
- **Customizable**: Users can modify system prompt and strategy

## Customization Points

Users can customize Noterie by editing files in `~/.noterie/`:

1. **`system-prompt.txt`**: Change AI behavior, timestamp format, response style
2. **`strategy.md`**: Define custom note-taking philosophy
3. **`noterie` script**: Change model, add new modes, modify prompts

## Installation Flow

```
User runs curl command
         ↓
install.sh downloads from GitHub
         ↓
Creates ~/.noterie/ directory
         ↓
Downloads: noterie, system-prompt.txt, strategy.md
         ↓
Makes noterie executable
         ↓
Creates empty notes.txt
         ↓
Detects shell (zsh/bash)
         ↓
Adds ~/.noterie to PATH in rc file
         ↓
Checks for opencode installation
         ↓
Displays success message
```

## Dependencies

- **Required**:
  - Bash or Zsh shell
  - OpenCode CLI (`opencode`)
  
- **Optional**:
  - `$EDITOR` environment variable (defaults to `nano`)

## Version Information

- **Version**: 1.0
- **License**: MIT
- **Repository**: https://github.com/Hyper-Unearthing/Noterie
- **Model**: OpenCode Grok Code Fast (`opencode/grok-code`)

## Design Decisions

### Why Bash?
- Simple, portable
- No dependencies beyond shell and opencode
- Easy to customize
- Works on all Unix-like systems

### Why Single Notes File?
- Follows append-and-review philosophy
- Simple CTRL+F searching
- No cognitive overhead of organizing folders
- Natural prioritization (recent = top)

### Why OpenCode?
- Powerful file operations
- Easy CLI integration
- Supports multiple AI models
- Good for local development workflows

### Why Dynamic Paths?
- Works in any installation location
- Easier testing and development
- No hardcoded assumptions
- More flexible for users

### Why Not Use `-f` Flag?
- OpenCode's Edit tool is more reliable for file modifications
- Direct file operations ensure consistency
- Simpler prompt construction
- Better control over file updates

## Future Enhancements (Potential)

- Config file for model selection
- Custom timestamp formats
- Multiple note files (tags/categories)
- Export/import functionality
- Integration with other note systems
- Web interface
- Sync capabilities
- Search improvements
- Review mode automation

## Testing

Tested functionality:
- ✅ Help command (`--help`)
- ✅ Quick note mode (`-n`)
- ✅ Query mode (`-q`)
- ✅ Append-to-top behavior
- ✅ Timestamp formatting
- ✅ File path resolution
- ✅ OpenCode integration
- ✅ Error handling (empty content)

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
# Check file permissions
ls -la ~/.noterie/notes.txt

# Verify file exists and is writable
touch ~/.noterie/notes.txt
```

### Editor not opening
```bash
# Check EDITOR variable
echo $EDITOR

# Set it if empty
export EDITOR=nano
```
