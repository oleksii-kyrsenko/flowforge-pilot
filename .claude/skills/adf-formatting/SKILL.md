---
name: adf-formatting
description: Atlassian Document Format (ADF) JSON reference for writing to Jira. Use whenever the pipeline posts a comment or description to Jira via Atlassian MCP (/spec posts the spec, /ship transitions/links the ticket). Companion to hard rule 8 — Jira writes use contentFormat "adf", never raw Markdown.
---

# ADF (Atlassian Document Format) reference

Per **hard rule 8**, every Jira write (comments, descriptions) via Atlassian MCP must use
`contentFormat: "adf"` with an ADF JSON document — never raw Markdown (Markdown renders
checkboxes and links as literal text). ADF gives proper headings, checklists, links, and
inline code.

## Document envelope

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    /* block nodes */
  ]
}
```

## Common block nodes

- **Heading**: `{ "type": "heading", "attrs": { "level": 2 }, "content": [ { "type": "text", "text": "Specification" } ] }`
- **Paragraph**: `{ "type": "paragraph", "content": [ { "type": "text", "text": "…" } ] }`
- **Bullet list**: `{ "type": "bulletList", "content": [ { "type": "listItem", "content": [ <paragraph> ] } ] }`
- **Code block**: `{ "type": "codeBlock", "attrs": { "language": "tsx" }, "content": [ { "type": "text", "text": "…" } ] }`

## Acceptance-criteria checklist → taskList (NOT a bullet list)

```json
{
  "type": "taskList",
  "attrs": { "localId": "ac" },
  "content": [
    {
      "type": "taskItem",
      "attrs": { "localId": "ac-1", "state": "TODO" },
      "content": [{ "type": "text", "text": "Renders all variant states" }]
    },
    {
      "type": "taskItem",
      "attrs": { "localId": "ac-2", "state": "DONE" },
      "content": [{ "type": "text", "text": "Meets a11y contrast" }]
    }
  ]
}
```

`state` is `"TODO"` or `"DONE"`. Each `taskItem` needs a unique `localId`.

## Inline marks (on `text` nodes)

- **Link**: `{ "type": "text", "text": "PR #12", "marks": [ { "type": "link", "attrs": { "href": "https://github.com/…/pull/12" } } ] }`
- **Inline code**: `{ "type": "text", "text": "ComponentName.tsx", "marks": [ { "type": "code" } ] }`
- **Bold / emphasis**: `{ "type": "strong" }` / `{ "type": "em" }`.

## Rules

- Always English. Always validate the JSON is well-formed before sending.
- Use `taskList`/`taskItem` for any checkbox content; `link` marks for any URL; `code`
  marks/`codeBlock` for any code or file path.
