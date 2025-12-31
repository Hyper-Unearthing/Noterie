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
└── last_note              # Temporary file (created/deleted as needed)

$NOTERIE_DIR/              # User-specified directory (can be anywhere)
└── (user's notes)         # Organized by AI according to strategy
```

## Core Components

### 1. `noterie` - Main Bash Script

**Purpose**: CLI entry point that orchestrates all functionality

**Key Variables**:
```bash
SCRIPT_DIR              # Directory where noterie is installed (~/.noterie)
NOTES_DIR               # Set to $NOTERIE_DIR environment variable
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

**Purpose**: Defines OpenCode's behavior and responsibilities, Users can edit this file to match their preferred approach

### 3. `strategy.md` - Note-taking Strategy

**Purpose**: Defines the note-taking philosophy, Users can edit this file to match their preferred approach


### 4. `install.sh` - Installation Script

**Purpose**: Download and set up Noterie on user's system

**Process**:
1. Create `~/.noterie/` directory
2. Download files from GitHub:
   - `noterie`
   - `system-prompt.txt`
   - `strategy.md`
3. Make `noterie` executable
4. Prompt user for notes directory path
5. Convert relative paths to absolute
6. Detect shell (zsh/bash)
7. Add `~/.noterie` to PATH in shell rc file
8. Export `NOTERIE_DIR` to shell rc file
9. Check if opencode is installed
10. Display success message with notes directory path

## Operating Modes

### Mode 1: Interactive Editor (`noterie`)

**Flow**:
1. Create/clear `last_note` file
2. Open `$EDITOR` (or vim) with `last_note`
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
The user has created a new note. Save it in the notes directory ($NOTERIE_DIR) according to your strategy.

## New Note Content
<contents from editor>
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
The user has a query about their notes. Search ALL files in $NOTERIE_DIR and provide a helpful, concise answer.

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
- **Read tool**: To read files in `$NOTERIE_DIR` directory
- **Write/Edit tools**: To create or modify files in `$NOTERIE_DIR`
- **Bash tool**: To get current timestamp
- **Grep/Glob tools**: To search across multiple files

### Output
- Full OpenCode response is displayed to user
- Typical response for append: "Note saved."
- Typical response for query: Direct answer with relevant note citations

## Data Flow

### Append Note Flow
```
User input → noterie script → Build prompt → OpenCode
                                               ↓
User ← Display output ← Return response ← Save to $NOTERIE_DIR
```

### Query Note Flow
```
User query → noterie script → Build prompt → OpenCode
                                               ↓
User ← Display output ← Return response ← Search $NOTERIE_DIR
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| OpenCode not installed | Show error, exit with code 1 |
| `$NOTERIE_DIR` not set | Show error, exit with code 1 |
| `$EDITOR` not set | Default to `vim` |
| Empty editor content | Show "No note added", skip OpenCode |
| Empty `-n` argument | Show error and usage |
| Empty `-q` argument | Show error and usage |
| `$NOTERIE_DIR` doesn't exist | Create directory automatically |
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
- **Local file storage**: All notes stored in user-specified `$NOTERIE_DIR`
- **No network requests**: Except to OpenCode API (via opencode CLI)
- **Customizable**: Users can modify system prompt and strategy

## Customization Points

Users can customize Noterie by editing files in `~/.noterie/`:

1. **`system-prompt.txt`**: Change AI behavior, timestamp format, response style
2. **`strategy.md`**: Define custom note-taking philosophy
3. **`NOTERIE_DIR`**: Specify the directory to save notes

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
  - `$EDITOR` environment variable (defaults to `vim`)
  
## Design Decisions

### Why Bash?
- Simple, portable
- No dependencies beyond shell and opencode
- Easy to customize
- Works on all Unix-like systems

### Why User-Specified Directory?
- Flexibility to use existing note directories
- Integration with cloud sync (Dropbox, iCloud, etc.)
- Users can choose their own version control setup
- No opinionated file organization
- Works with existing workflows
- AI decides structure based on user's strategy
- Search across all files seamlessly

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
