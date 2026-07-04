"""MkDocs build hooks for RENAR.

Numeric anchor injection — RENAR markdown uses ISO-style heading numbers
(`## §10.1 Назначение`, `### 10.3.6 QG-0`) and links to them via `#10.1`,
`#10.3.6`. The default toc/github slugify strips dots, producing slugs like
`101` and `1036`, so direct numeric links 404.

This hook intercepts the page's markdown BEFORE render and inserts a standalone
`<a id="N.M.K"></a>` element on the line preceding every heading whose visible
text starts with `§?N(.M)+`. The heading keeps its auto-generated slug
(`101-naznachenie`) so any TOC-style anchor `#101-naznachenie` still works,
AND the numeric anchor `#N.M.K` becomes valid via the inline element.

Skipped if our anchor already precedes the heading (idempotent).

Wired via mkdocs.yml `hooks:` — no md source mutations.
"""

import re

# Headings: any depth, optional § prefix, then N(.M)+ where each N is digits.
# Pattern requires at least one dot to avoid false positives on bullets like
# "## 2 RFC-2119" (single number — keep default slug). To include single-number
# anchors flip `{1,}` to `{0,}` on the (\.\d+) group.
_HEADING_RE = re.compile(
    r"^(?P<hash>#{1,6})\s+§?(?P<num>\d+(?:\.\d+)+)\b(?P<rest>.*)$",
    re.MULTILINE,
)


def _inject_anchor(match: "re.Match[str]") -> str:
    line = match.group(0)
    num = match.group("num")
    anchor = f'<a id="{num}"></a>'
    start = match.start()
    if start > 0:
        before = match.string[:start]
        last_lines = before.rsplit("\n", 2)
        if len(last_lines) >= 2 and anchor in last_lines[-2]:
            return line
    return f"{anchor}\n{line}"


def on_page_markdown(markdown: str, **_kwargs) -> str:
    """Insert `<a id="N.M.K"></a>` before numeric headings — additive, keeps default slug."""
    return _HEADING_RE.sub(_inject_anchor, markdown)
