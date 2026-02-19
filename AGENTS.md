# AGENTS.md

This repository contains zero-dependency tools for exporting Markdown files to standalone HTML files with Mermaid diagram support.

**Available Implementations:**
- Emacs Lisp package (`markdown-export.el`)
- Node.js CLI utility (`md2html.js`)
- Neovim Lua module (`markdown-export.lua`)

## Project Overview

**Primary Purpose**: Convert Markdown files to self-contained HTML files that render perfectly in any modern browser without external dependencies.

**Key Features**:
- Mermaid diagram rendering (via embedded CDN)
- YAML frontmatter support (title, thumbnail, date, authors)
- Dark/light theme toggle with OS preference detection
- GitHub-flavored Markdown rendering
- Zero runtime dependencies (uses CDNs for JavaScript libraries)

## Project Structure

```
markdown-export/
├── markdown-export.el    # Main Emacs Lisp package
├── md2html.js           # Node.js CLI utility (same functionality)
├── markdown-export.lua  # Neovim Lua module (same functionality)
├── test.md              # Example markdown file with frontmatter
├── README.md            # User documentation
├── LICENSE              # MIT License
└── .gitignore          # Generated .html files are ignored
```

## Code Organization

### Main Package (`markdown-export.el`)

- **Entry Points**: Two autoloaded interactive functions
  - `markdown-export-with-mermaid` - Export to HTML file, return path
  - `markdown-export-with-mermaid-and-open` - Export and open in browser

- **Core Logic** (in `markdown-export-with-mermaid` function):
  1. Reads current buffer content
  2. Base64-encodes UTF-8 markdown
  3. Constructs HTML template with embedded content
  4. Writes to `.html` file (same basename as source)

- **Dependencies**:
  - Requires: `emacs "27.1"`, `markdown-mode "2.0"`
  - No runtime dependencies - uses CDNs in generated HTML

### Node.js Utility (`md2html.js`)

- **Purpose**: Command-line alternative to Emacs package
- **Usage**: `node md2html.js <file.md> [file2.md ...]`
- **Output**: Creates `.html` files alongside input files
- **Architecture**: Mirrors the Elisp implementation exactly

### Neovim Lua Module (`markdown-export.lua`)

- **Purpose**: Neovim plugin alternative to Emacs package
- **Usage**: `:MarkdownExportWithMermaid` or `:MarkdownExportWithMermaidAndOpen` in a markdown buffer
- **Output**: Creates `.html` file in the same directory as the source markdown
- **Architecture**: Mirrors the Elisp implementation exactly
- **Setup**: Call `require('markdown-export').setup()` to create commands
- **Dependencies**: None (uses shell commands for Base64 encoding)

## Code Patterns and Conventions

### Emacs Lisp

1. **Function Naming**: All functions use `markdown-export-` prefix
2. **Lexical Binding**: File header uses `;;; -*- lexical-binding: t; -*-`
3. **Interactive Commands**: Marked with `;;;###autoload` before interactive functions
4. **Error Handling**: Validates buffer has a file before processing
5. **Template Formatting**: Uses `format` function with `%s` placeholders, escapes `%` as `%%`
6. **Encoding**: Base64-encodes UTF-8 content using `base64-encode-string` with `t` argument (no newlines)

### JavaScript (CLI)

1. **CommonJS Module**: Uses `require()` for Node.js compatibility
2. **Template Literals**: Uses backtick strings with `${}` interpolation
3. **Buffer Handling**: Uses `Buffer.from(markdown).toString('base64')`
4. **Error Handling**: Checks file existence before processing, logs errors but continues

### Lua (Neovim)

1. **Module Pattern**: Returns a table `M` with functions as keys
2. **String Format**: Uses `string.format()` with `[[...]]` for multi-line strings and `%s` placeholders
3. **Buffer Access**: Uses `vim.api.nvim_buf_get_lines()` to read buffer content
4. **Base64 Encoding**: Uses shell command `base64 -w 0` via `vim.fn.system()`
5. **File I/O**: Uses standard Lua `io.open()`, `io:write()`, `io:close()`
6. **Error Handling**: Uses `vim.notify()` with log levels for errors/info
7. **Command Creation**: Uses `vim.api.nvim_create_user_command()` to expose user commands

### HTML Template (embedded in both files)

1. **CDN Dependencies**:
   - `github-markdown-css` (light/dark themes)
   - `marked` (Markdown parser)
   - `js-yaml` (YAML frontmatter parser)
   - `mermaid` (Diagram renderer)

2. **Frontmatter Parsing**:
   - Detects `---\n` or `---\r\n` delimiters
   - Supports: `title`, `thumbnail`, `date`, `authors` (array of objects)
   - Authors can be strings or objects with `name` and `affiliations`

3. **Mermaid Integration**:
   - Finds `code.language-mermaid` blocks
   - Replaces `<pre><code>` with `<div class="mermaid">`
   - Stores original code in `data-original-code` attribute
   - Re-renders on theme toggle

4. **Theme Toggle**:
   - Respects OS preference on load (`prefers-color-scheme`)
   - Updates both CSS and Mermaid theme on toggle
   - Fixed position button in top-right corner

## Important Gotchas

### Template Duplication

The HTML template is **duplicated** between all three files. When making changes:
- Update `markdown-export.el`, `md2html.js`, and `markdown-export.lua` identically
- Pay attention to escaping differences:
  - Elisp: Use `%%` for literal `%` in format strings
  - JavaScript: Use `${}` for interpolation, escape backticks as needed
  - Lua: Use `%%` for literal `%` in `string.format()` (like Elisp)

### String Escaping in Elisp

The `format` function requires special handling:
- Use `%%` to represent a literal `%` character
- Example in CSS: `width: 100%%;` (line 56)
- The title parameter is escaped: `(replace-regexp-in-string "%" "%%" ...)` (line 29)

### Base64 Encoding Differences

- **Elisp**: `(base64-encode-string (encode-coding-string markdown-content 'utf-8) t)`
  - The `t` argument removes newlines from Base64 output
- **JavaScript**: `Buffer.from(markdown).toString('base64')`
  - Automatically produces newlines-free output
- **Lua**: `vim.fn.system("echo -n " .. vim.fn.shellescape(markdown_content) .. " | base64 -w 0")`
  - Uses shell command with `-w 0` flag to remove newlines

### Frontmatter Handling

- YAML must be between `---` delimiters at file start
- After parsing, frontmatter is **removed** from the markdown body
- Title from frontmatter overrides the document `<title>` tag
- Errors in YAML parsing are caught and logged to console (don't break rendering)

### Mermaid Rendering

- Mermaid must be initialized with `startOnLoad: false` (manual control)
- Theme must match the CSS theme: `'dark'` or `'default'`
- When toggling themes, Mermaid divs must be reset:
  - Remove `data-processed` attribute
  - Restore original code from `data-original-code`
  - Call `mermaid.run()` again

### File Naming

- Output file uses same basename as input with `.html` extension
- Example: `test.md` → `test.html`
- Generated HTML files are gitignored (see `.gitignore`)

## Testing

No automated test suite exists. Manual testing approach:

1. **Test Markdown** (`test.md`):
   - Contains comprehensive frontmatter example
   - Includes multiple Mermaid diagram types
   - Has code blocks and standard markdown

2. **Manual Testing**:
    ```bash
    # Using Node.js CLI
    node md2html.js test.md
    # Open generated test.html in browser

    # Using Emacs
    M-x markdown-export-with-mermaid-and-open

    # Using Neovim
    :MarkdownExportWithMermaidAndOpen
    ```

3. **Validation Checklist**:
   - Frontmatter displays correctly (title, thumbnail, date, authors)
   - Mermaid diagrams render properly
   - Theme toggle works and updates Mermaid
   - Dark mode respects OS preference
   - HTML file is standalone (opens without internet if CDNs are cached)
   - Generated HTML is ignored by git

## Dependencies

**Runtime Dependencies** (none - all in generated HTML via CDNs):
- marked@12.0.0
- js-yaml@4.1.0
- mermaid@10
- github-markdown-css@5.5.0

**Development Dependencies**:
- Emacs 27.1+ (for markdown-export.el)
- markdown-mode 2.0+
- Node.js (for md2html.js utility)
- Neovim 0.5+ (for markdown-export.lua)

## Package Installation

Users install this as an Emacs package via:
- `straight.el` (recommended)
- `quelpa`
- Doom Emacs package system

Installation instructions are in `README.md`.

## Code Style

- **Elisp**: Standard Emacs Lisp conventions, use `lexical-binding: t`
- **JavaScript**: CommonJS style, standard ES6+ features
- **HTML/CSS**: Minimal, follows GitHub's markdown.css patterns
- **Lua**: Module pattern returning table `M`, standard Neovim API conventions
- **Indentation**: 4 spaces (Elisp, JavaScript, Lua)

## Making Changes

1. **Update Both Files**: Always modify `markdown-export.el`, `md2html.js`, and `markdown-export.lua` when changing the HTML template
2. **Test Manually**: Run all three implementations to verify consistency
3. **Validate HTML**: Open generated HTML in multiple browsers
4. **Check Themes**: Test both light and dark modes with Mermaid diagrams
5. **Ignore Output**: Ensure `.gitignore` contains `*.html` pattern

## Common Tasks

### Add a New CDN Dependency

Add `<script>` or `<link>` tags in the HTML template section (around lines 58-59 in Elisp, 34-35 in JS, 38-39 in Lua).

### Modify CSS Styling

Edit the `<style>` block in the HTML template (around lines 38-57 in Elisp, 14-32 in JS, 18-37 in Lua).

### Change Frontmatter Fields

Modify the frontmatter parsing logic in the embedded JavaScript (around lines 84-124 in Elisp, 59-100 in JS, 75-116 in Lua).

### Adjust Mermaid Configuration

Change the `mermaid.initialize()` call (around line 139 in Elisp, line 115 in JS, line 134 in Lua).
