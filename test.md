---
title: Test Article with Mermaid Diagrams
thumbnail: ./image.jpg
date: 2026-02-19
authors:
  - name: Robert Zaremba
    affiliations:
      - My Corp
  - name: Jonny Jonny
    affiliations:
      - Example Corp
      - Another Org
---

# Introduction

This is a **test document** to demonstrate the markdown to HTML converter with Mermaid support.

## Features

- GitHub-flavored Markdown
- Mermaid diagram rendering
- Dark/Light theme toggle
- YAML frontmatter support

## Mermaid Diagrams

### Flowchart

```mermaid
graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> B
```

### Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant Browser
    participant Server
    User->>Browser: Click link
    Browser->>Server: HTTP Request
    Server-->>Browser: HTML Response
    Browser-->>User: Display page
```

## Code Example

```javascript
function greet(name) {
    return `Hello, ${name}!`;
}
console.log(greet('World'));
```

## Conclusion

This converter produces standalone HTML files that render perfectly in any modern browser.
