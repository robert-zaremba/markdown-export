# markdown-export.el

A zero-dependency Emacs package to export Markdown files to beautifully styled, standalone HTML files.

Instead of relying on external command-line tools like Pandoc, this package Base64-encodes your Markdown and wraps it in a self-rendering HTML template. This ensures perfect portability—you can email the generated HTML file, and it will render perfectly in any modern browser.

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

### Standard Emacs (use-package + straight.el / quelpa)

``` emacs-lisp
(use-package markdown-export
  :straight (markdown-export :type git :host github :repo "yourusername/markdown-export")
  :after markdown-mode
  :bind (:map markdown-mode-map
         ("C-c C-e m" . markdown-export-with-mermaid)
         ("C-c C-e o" . markdown-export-with-mermaid-and-open)))
```

### Doom Emacs

Add the following to your `packages.el`:
```elisp
(package! markdown-export
  :recipe (:host github :repo "robert-zaremba/markdown-export"))

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

## Usage

While in any markdown-mode buffer:

* Run `M-x markdown-export-with-mermaid` to silently compile the file.
* Run `M-x markdown-export-with-mermaid-and-open` to compile the file and immediately view it in your default web browser.
