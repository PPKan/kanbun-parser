# Compile And Adjust Output

This document is the parameter guide for the CLI build pipeline.

## Build Inputs

Use one of the sample Markdown files in `examples/`:

- `examples/linear-kundoku.md`: vertical kundoku prototype
- `examples/academic-paper.md`: full document sample
- `examples/minimal-kanbun.md`: kanbun-only sample

Default branch prototype command:

```bash
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku.pdf --emit-tex out/linear-kundoku.tex
```

Horizontal reference command:

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

1. selected built-in preset: `linear` or `academic`
2. project config: `jpmd.yml`
3. document frontmatter override: `jpmd:`

In this branch, `jpmd.yml` sets `default_preset: linear`, while `examples/academic-paper.md` pins itself to `academic`.

You can also choose a preset explicitly:

```bash
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku.pdf --preset linear
```

```bash
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --preset academic
```

## Per-Document Overrides

Add `jpmd:` in a Markdown file when you want a document-local layout change.

```yaml
---
jpmd:
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

## Temporary Project Override File

If you do not want to edit `jpmd.yml`, create a second config file and pass `--config`.

```yaml
default_preset: linear

presets:
  linear:
    layout:
      writing_mode: tate
      grid:
        characters_per_line: 20
        lines_per_page: 10
      font:
        body_size: 13pt
```

```bash
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku-test.pdf --emit-tex out/linear-kundoku-test.tex --config jpmd.test.yml
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

The CLI validates settings before LaTeX runs.

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

1. Change one parameter.
2. Rebuild with `--emit-tex`.
3. Inspect the PDF.
4. If needed, inspect the emitted TeX.

Fast loop:

```bash
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku.pdf --emit-tex out/linear-kundoku.tex
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
