# markdown-export

Zero-dependency tools to export Markdown files to beautifully styled, standalone HTML files.

Instead of relying on external command-line tools like Pandoc, these tools Base64-encode your Markdown and wrap it in a self-rendering HTML template. This ensures perfect portability—you can email the generated HTML file, and it will render perfectly in any modern browser.

- **markdown-export.el** — Emacs package
- **md2html.js** — Node.js CLI script
- **markdown-export.lua** — Neovim Lua module

## Features

* **Mermaid JS Support:** Renders standard `mermaid` code blocks automatically.
* **YAML Frontmatter:** Parses title, thumbnail, date, and authors into a clean header.
* **GitHub Markdown CSS:** Looks great out of the box.
* **Dark/Light Mode:** Includes a built-in theme toggle that respects your OS settings on initial load.

Example Frontmatter (put it at the top of the file):

``` yaml
---
title: My First Article
thumbnail: ./thumbnails/nice-image.png
date: 2026-02-11
authors:
  - name: Robert Zaremba
    affiliations:
      - Your Company
---
```


## Installation

### Node.js

No installation required — just run the script directly with Node or Bun (see usage section).

### Emacs (use-package + straight.el / quelpa)

``` emacs-lisp
(use-package markdown-export
  :straight (markdown-export :type git :host github :repo "robert-zaremba/markdown-export")
  :after markdown-mode
  :bind (:map markdown-mode-map
         ("C-c C-e m" . markdown-export-with-mermaid)
         ("C-c C-e o" . markdown-export-with-mermaid-and-open)))
```

### Emacs - Doom

Add the following to your `packages.el`:

```elisp
(package! markdown-export
  :recipe (:host github :repo "robert-zaremba/markdown-export"))
```

Then in your config.el:

``` emacs-lisp
(use-package! markdown-export
  :after markdown-mode
  :config
  (map! :map markdown-mode-map
        :localleader
         (:prefix ("c" . "compile/export")
          :desc "Export HTML w/ Mermaid"          "m" #'markdown-export-with-mermaid
          :desc "Export HTML w/ Mermaid & Open"   "o" #'markdown-export-with-mermaid-and-open)))
```

### Neovim (lazy.nvim)

Add to your lazy.nvim plugin specification:

```lua
{
  "robert-zaremba/markdown-export",
  config = function()
    require('markdown-export').setup()
  end,
  ft = "markdown",
}
```

With keybindings:

```lua
{
  "robert-zaremba/markdown-export",
  config = function()
    require('markdown-export').setup()
    vim.keymap.set('n', '<leader>me', ':MarkdownExportWithMermaid<CR>', { desc = 'Export Markdown to HTML' })
    vim.keymap.set('n', '<leader>mo', ':MarkdownExportWithMermaidAndOpen<CR>', { desc = 'Export Markdown and open' })
  end,
  ft = "markdown",
}
```

### Neovim (packer.nvim)

```lua
use 'robert-zaremba/markdown-export'
```

### Neovim (vim-plug)

```vim
Plug 'robert-zaremba/markdown-export'
```

### Neovim (Manual)

Clone the repository to your Neovim config directory:

```bash
git clone https://github.com/robert-zaremba/markdown-export.git ~/.config/nvim/lua/markdown-export
```

Then add to your `init.lua`:

```lua
require('markdown-export').setup()
```

## Usage

### Bun or Node.js

Note: use `node` if you prefer it over `bun`

```bash
bun md2html.js document.md              # Creates document.html
bun md2html.js file1.md file2.md ...    # Process multiple files
```

### Emacs

While in any markdown-mode buffer:

* Run `M-x markdown-export-with-mermaid` to silently compile the file.
* Run `M-x markdown-export-with-mermaid-and-open` to compile the file and immediately view it in your default web browser.

### Neovim

While editing a markdown file:

* Run `:MarkdownExportWithMermaid` to export the file to HTML.
* Run `:MarkdownExportWithMermaidAndOpen` to export and open in your default browser.
* Or use the keybindings defined in your config (e.g., `<leader>me` or `<leader>mo`).
