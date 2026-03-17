# Compile And Adjust Output

This document is the parameter guide for the CLI build pipeline.

## Build Inputs

Use one of the sample Markdown files in `examples/`:

- `examples/academic-paper.md`: full document sample
- `examples/minimal-kanbun.md`: kanbun-only sample

Main command:

```bash
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --emit-tex out/academic-paper.tex
```

Minimal kanbun command:

```bash
ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
```

## Build Stack

The project builds Markdown to PDF with:

- `Pandoc`
- `LuaLaTeX`
- `jlreq`
- `filter.lua`
- `template.tex`
- `templates/preamble.tex.erb`
- `jpmd.yml`

## Configuration Order

Settings are applied in this order:

1. built-in preset: `academic`
2. project config: `jpmd.yml`
3. document frontmatter override: `jpmd:`

You can also choose a preset explicitly:

```bash
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --preset academic
```

## Per-Document Overrides

Add `jpmd:` in a Markdown file when you want a document-local layout change.

```yaml
---
jpmd:
  layout:
    grid:
      characters_per_line: 28
      lines_per_page: 32
    font:
      body_size: 11pt
  kanbun:
    furigana:
      size: 8pt
      shift:
        up: 1pt
        right: 0pt
        down: 0pt
        left: 0pt
---
```

## Temporary Project Override File

If you do not want to edit `jpmd.yml`, create a second config file and pass `--config`.

```yaml
default_preset: academic

presets:
  academic:
    layout:
      grid:
        characters_per_line: 20
        lines_per_page: 25
      font:
        body_size: 11pt
```

```bash
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper-test.pdf --emit-tex out/academic-paper-test.tex --config jpmd.test.yml
```

## Adjustable Parameters

Layout settings:

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

The CLI validates settings before LaTeX runs.

Important checks:

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

1. Change one parameter.
2. Rebuild with `--emit-tex`.
3. Inspect the PDF.
4. If needed, inspect the emitted TeX.

Fast loop:

```bash
ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
```

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

- layout variations
- baseline kanbun rendering
- furigana movement
- kaeriten movement
- okurigana movement

## Files Worth Editing

- `examples/academic-paper.md`
- `examples/minimal-kanbun.md`
- `jpmd.yml`
- `templates/preamble.tex.erb`
- `test/variation_suite.yml`
- `scripts/run_visual_suite.rb`
