# Compile And Adjust Output

This document is the YAML-frontmatter guide for the build pipeline.

## Build Command

Run builds from the repo root:

```bash
ruby bin/jpmd build examples/minimal-kanbun.md
ruby bin/jpmd build examples/linear-kundoku.md
ruby bin/jpmd build examples/academic-paper.md
```

The CLI now needs only the input Markdown path. PDF output defaults to `out/<input-basename>.pdf`.

## Configuration Sources

Settings are applied in this order:

1. built-in preset: `linear` or `academic`
2. optional project config: `jpmd.yml`
3. document-local override: `jpmd:` frontmatter

`jpmd.yml` is optional. A document with no `jpmd:` block still builds with defaults.

## Frontmatter Layout

Keep standard Pandoc metadata at the top level, and keep JPMD settings under `jpmd:`.

```yaml
---
title: Sample Title
bibliography: ../references/sample-zotero.json
csl: ../references/word-japanese-note.csl
jpmd:
  preset: academic
  output:
    tex: ../out/sample.tex
  layout:
    grid:
      characters_per_line: 30
      lines_per_page: 30
---
```

Rules:

- `bibliography:` and `csl:` stay at the top level.
- `jpmd.preset` selects `linear` or `academic`.
- `jpmd.output.pdf` is optional. If omitted, JPMD writes `out/<input-basename>.pdf` from the repo root.
- `jpmd.output.tex` is optional. If omitted, no TeX file is emitted.
- Relative paths in `bibliography`, `csl`, and `jpmd.output.*` are resolved relative to the Markdown file.

## Per-Document Overrides

Use `jpmd:` when you need document-local layout or kanbun adjustments.

```yaml
---
jpmd:
  preset: linear
  layout:
    writing_mode: tate
    grid:
      characters_per_line: 24
      lines_per_page: 11
    font:
      body_size: 14pt
  kanbun:
    furigana:
      size: 8pt
      shift:
        up: 0pt
        right: 0.20zw
        down: 0pt
        left: 0pt
---
```

## Adjustable Parameters

Layout settings:

- `layout.writing_mode`
- `layout.margins.top`
- `layout.margins.right`
- `layout.margins.bottom`
- `layout.margins.left`
- `layout.grid.characters_per_line`
- `layout.grid.lines_per_page`
- `layout.font.body_size`

Kanbun settings:

- `kanbun.side.gap`
- `kanbun.side.min_width`
- `kanbun.furigana.size`
- `kanbun.furigana.shift.up`
- `kanbun.furigana.shift.right`
- `kanbun.furigana.shift.down`
- `kanbun.furigana.shift.left`
- `kanbun.kaeriten.size`
- `kanbun.kaeriten.shift.up`
- `kanbun.kaeriten.shift.right`
- `kanbun.kaeriten.shift.down`
- `kanbun.kaeriten.shift.left`
- `kanbun.okurigana.size`
- `kanbun.okurigana.shift.up`
- `kanbun.okurigana.shift.right`
- `kanbun.okurigana.shift.down`
- `kanbun.okurigana.shift.left`

## Units

Physical layout units:

- `pt`
- `mm`
- `cm`
- `in`

Kanbun annotation units also allow:

- `bp`
- `dd`
- `cc`
- `sp`
- `ex`
- `em`
- `zw`
- `zh`

## Validation

The build validates settings before LuaLaTeX runs.

Important checks:

- `writing_mode` must be `yoko` or `tate`
- `characters_per_line` must be an integer and at least `2`
- `lines_per_page` must be an integer and at least `1`
- body size must be positive
- kanbun `size` values must be positive
- kanbun `shift` values must be nonnegative
- impossible layouts that require negative `kanjiskip` are rejected

## Kanbun Markdown Syntax

```markdown
[Base]{f="furigana" o="okurigana" k="kaeriten"}
```

Meaning:

- `f`: furigana
- `o`: okurigana
- `k`: kaeriten

## Recommended Adjustment Loop

1. Change one frontmatter value.
2. Rebuild with `ruby bin/jpmd build path/to/document.md`.
3. Inspect the PDF.
4. If needed, set `jpmd.output.tex` and inspect the emitted TeX.

## Visual Regression Report

Generate the suite:

```bash
ruby scripts/run_visual_suite.rb
```

Open:

```text
out/variation-suite/report.html
```

The suite covers:

- vertical layout variations
- baseline kanbun rendering
- furigana movement
- kaeriten movement
- okurigana movement

## Files Worth Editing

- `examples/linear-kundoku.md`
- `examples/academic-paper.md`
- `examples/minimal-kanbun.md`
- `jpmd.yml`
- `templates/preamble.tex.erb`
- `test/variation_suite.yml`
- `scripts/run_visual_suite.rb`
