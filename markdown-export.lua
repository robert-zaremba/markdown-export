--- markdown-export.lua --- Export Markdown to HTML with Mermaid ---

-- Author: Robert Zaremba
-- Version: 1.0
-- Description: Exports current Markdown buffer to a standalone HTML file with Mermaid diagrams, YAML Frontmatter, and dark/light theme toggle.

local M = {}

local function generate_html(title, b64_content)
  return string.format([[<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>%s</title>
    <link id="markdown-css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.0/github-markdown-light.min.css">
    <link id="highlight-css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
    <style>
        body { margin: 0; transition: background-color 0.3s ease; }
        .markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; padding-top: 60px; }
        @media (max-width: 767px) { .markdown-body { padding: 15px; padding-top: 60px; } }
        .mermaid { display: flex; justify-content: center; margin: 2em 0; }

        #theme-toggle {
            position: fixed; top: 15px; right: 15px; padding: 8px 12px;
            font-size: 14px; cursor: pointer; border: 1px solid #d0d7de;
            border-radius: 6px; background-color: #f6f8fa; color: #24292f;
            box-shadow: 0 1px 0 rgba(27,31,36,0.04); transition: all 0.2s ease; z-index: 1000;
        }
        #theme-toggle:hover { background-color: #f3f4f6; }

        body.dark-mode { background-color: #0d1117; }
        body.dark-mode #theme-toggle { background-color: #21262d; color: #c9d1d9; border-color: #30363d; }
        body.dark-mode #theme-toggle:hover { background-color: #30363d; }

        .frontmatter-header img { max-height: 300px; width: 100%%; object-fit: cover; border-radius: 6px; margin-bottom: 1em; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/marked@12.0.0/marked.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/js-yaml/4.1.0/js-yaml.min.js"></script>
</head>
<body class="markdown-body">
    <button id="theme-toggle">Switch to Dark Theme</button>
    <div id="content">Rendering Markdown...</div>

    <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
        import hljs from 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/highlight.min.js';

        let isDarkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        const themeToggleBtn = document.getElementById('theme-toggle');
        const markdownCss = document.getElementById('markdown-css');
        const highlightCss = document.getElementById('highlight-css');

        function updateThemeStyles() {
            if (isDarkMode) {
                markdownCss.href = 'https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.0/github-markdown-dark.min.css';
                highlightCss.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css';
                document.body.classList.add('dark-mode');
                themeToggleBtn.textContent = 'Switch to Light Theme';
            } else {
                markdownCss.href = 'https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.0/github-markdown-light.min.css';
                highlightCss.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css';
                document.body.classList.remove('dark-mode');
                themeToggleBtn.textContent = 'Switch to Dark Theme';
            }
        }

        updateThemeStyles();

        const base64Markdown = "%s";
        const binString = atob(base64Markdown);
        const bytes = Uint8Array.from(binString, (m) => m.codePointAt(0));
        let rawMarkdown = new TextDecoder().decode(bytes);

        // Process YAML Frontmatter
        let headerHtml = '';
        if (rawMarkdown.startsWith('---\n') || rawMarkdown.startsWith('---\r\n')) {
            const match = rawMarkdown.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
            if (match) {
                try {
                    const frontmatter = jsyaml.load(match[1]);
                    rawMarkdown = rawMarkdown.slice(match[0].length); // Remove frontmatter from the markdown body

                    if (frontmatter.title) document.title = frontmatter.title;

                    headerHtml += '<div class="frontmatter-header">';
                    if (frontmatter.thumbnail) {
                        headerHtml += `<img src="${frontmatter.thumbnail}" alt="Thumbnail">`;
                    }
                    if (frontmatter.title) {
                        headerHtml += `<h1>${frontmatter.title}</h1>`;
                    }
                    if (frontmatter.date) {
                        const dateStr = frontmatter.date instanceof Date ? frontmatter.date.toLocaleDateString() : frontmatter.date;
                        headerHtml += `<p><strong>Date:</strong> ${dateStr}</p>`;
                    }
                    if (frontmatter.authors) {
                        headerHtml += `<p><strong>Authors:</strong></p><ul>`;
                        const authors = Array.isArray(frontmatter.authors) ? frontmatter.authors : [frontmatter.authors];
                        authors.forEach(author => {
                            if (typeof author === 'string') {
                                headerHtml += `<li>${author}</li>`;
                            } else {
                                let name = author.name || 'Unknown';
                                let affil = author.affiliations ? ` <em>(${Array.isArray(author.affiliations) ? author.affiliations.join(', ') : author.affiliations})</em>` : '';
                                headerHtml += `<li>${name}${affil}</li>`;
                            }
                        });
                        headerHtml += `</ul>`;
                    }
                    headerHtml += '<hr></div>';
                } catch (e) {
                    console.error('Failed to parse YAML frontmatter:', e);
                }
            }
        }

        // Render remaining Markdown and prepend the generated Header
        document.getElementById('content').innerHTML = headerHtml + marked.parse(rawMarkdown);

        // Process Mermaid blocks first (remove them before highlighting)
        document.querySelectorAll('code.language-mermaid').forEach((block) => {
            const pre = block.parentElement;
            const div = document.createElement('div');
            div.className = 'mermaid';
            div.setAttribute('data-original-code', block.textContent);
            div.textContent = block.textContent;
            pre.replaceWith(div);
        });

        // Apply syntax highlighting to remaining code blocks
        hljs.highlightAll();

        async function renderMermaid() {
            mermaid.initialize({ startOnLoad: false, theme: isDarkMode ? 'dark' : 'default' });
            document.querySelectorAll('.mermaid').forEach(el => {
                el.removeAttribute('data-processed');
                el.innerHTML = el.getAttribute('data-original-code');
            });
            try { await mermaid.run({ querySelector: '.mermaid' }); }
            catch (error) { console.error('Mermaid render error:', error); }
        }

        renderMermaid();

        themeToggleBtn.addEventListener('click', async () => {
            isDarkMode = !isDarkMode;
            updateThemeStyles();
            await renderMermaid();
        });
    </script>
</body>
</html>]], title, b64_content)
end

function M.export_with_mermaid()
  local bufnr = 0
  local buf_name = vim.api.nvim_buf_get_name(bufnr)

  if buf_name == "" then
    vim.notify("Buffer is not visiting a file", vim.log.levels.ERROR)
    return nil
  end

  local markdown_content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
  local b64_content = vim.fn.system("echo -n " .. vim.fn.shellescape(markdown_content) .. " | base64 -w 0"):gsub("\n", "")
  local output_file = vim.fn.fnamemodify(buf_name, ":r") .. ".html"
  local title = vim.fn.fnamemodify(buf_name, ":t")

  local html = generate_html(title, b64_content)

  local file = io.open(output_file, "w")
  if not file then
    vim.notify("Failed to write to " .. output_file, vim.log.levels.ERROR)
    return nil
  end

  file:write(html)
  file:close()

  vim.notify("Successfully exported to " .. output_file, vim.log.levels.INFO)
  return output_file
end

function M.export_with_mermaid_and_open()
  local output_file = M.export_with_mermaid()
  if output_file then
    vim.ui.open("file://" .. output_file)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("MarkdownExportWithMermaid", M.export_with_mermaid, { desc = "Export Markdown to HTML with Mermaid" })
  vim.api.nvim_create_user_command("MarkdownExportWithMermaidAndOpen", M.export_with_mermaid_and_open, { desc = "Export Markdown to HTML with Mermaid and open" })
end

return M
