# Compile And Adjust JPMD Output

This document explains how to compile the current project and how to tune the parameters yourself.

## 1. What this build does

The current CLI builds Markdown to PDF with:

- `Pandoc`
- `LuaLaTeX`
- `jlreq`
- the custom kanbun Lua filter in [filter.lua](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/filter.lua)
- the generated preamble in [templates/preamble.tex.erb](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/templates/preamble.tex.erb)
- the project defaults in [jpmd.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/jpmd.yml)

The main entrypoint is [bin/jpmd](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/bin/jpmd).

## 2. Requirements

You need:

- Ruby
- Pandoc
- LuaLaTeX
- the TeX packages already used by this repo, especially `jlreq` and `luatexja-ruby`

The compiler looks for:

- `pandoc` on `PATH`, or `PANDOC_PATH`
- `lualatex` on `PATH`, or `LUALATEX_PATH`

On this machine the usual locations are:

```powershell
$env:PANDOC_PATH = 'C:\Users\peter\AppData\Local\Pandoc\pandoc.exe'
$env:LUALATEX_PATH = 'C:\texlive\2025\bin\windows\lualatex.exe'
```

## 3. Basic compile command

From the project root:

```powershell
ruby bin\jpmd build document.md -o out\document.pdf --emit-tex out\document.tex
```

This writes:

- the PDF to `out\document.pdf`
- the generated TeX to `out\document.tex`

If you only want the PDF:

```powershell
ruby bin\jpmd build document.md -o out\document.pdf
```

## 4. How settings are resolved

Settings are applied in this order:

1. Built-in preset: `academic`
2. Project config: [jpmd.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/jpmd.yml)
3. Per-document frontmatter override: `jpmd:`

You can also choose a preset explicitly:

```powershell
ruby bin\jpmd build document.md -o out\document.pdf --preset academic
```

## 5. Project-wide parameter editing

Edit [jpmd.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/jpmd.yml) when you want the change to affect all builds that use the project default.

Current default structure:

```yaml
default_preset: academic

presets:
  academic:
    layout:
      margins:
        top: 2.5cm
        right: 3cm
        bottom: 2.5cm
        left: 3cm
      grid:
        characters_per_line: 30
        lines_per_page: 30
      font:
        body_size: 12pt
    kanbun:
      side:
        gap: 0.10zw
        min_width: 0.35zw
      furigana:
        size: 7pt
        shift:
          up: 0pt
          right: 0pt
          down: 0pt
          left: 0pt
      kaeriten:
        size: 7pt
        shift:
          up: 0pt
          right: 0pt
          down: 0.35ex
          left: 0pt
      okurigana:
        size: 7pt
        shift:
          up: 0pt
          right: 0pt
          down: 0pt
          left: 0pt
```

## 6. Per-document overrides

If you want to test only one Markdown file, add `jpmd:` in that file's YAML frontmatter.

Example:

```yaml
---
numbersections: true
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

That override affects only that Markdown file.

## 7. Temporary test config without touching the main config

If you want to experiment without changing [jpmd.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/jpmd.yml), create a separate YAML file and pass it with `--config`.

Example `jpmd.test.yml`:

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
    kanbun:
      furigana:
        size: 8pt
        shift:
          up: 2pt
          right: 1pt
          down: 0pt
          left: 0pt
```

Compile with it:

```powershell
ruby bin\jpmd build document.md -o out\document-test.pdf --emit-tex out\document-test.tex --config jpmd.test.yml
```

## 8. Adjustable parameters

### Layout

You can adjust:

- `layout.margins.top`
- `layout.margins.right`
- `layout.margins.bottom`
- `layout.margins.left`
- `layout.grid.characters_per_line`
- `layout.grid.lines_per_page`
- `layout.font.body_size`

Meaning:

- `margins.*`: page margins
- `characters_per_line`: full-width Japanese character count target
- `lines_per_page`: total line slots per page, including blank lines
- `body_size`: body text size for both Latin and Japanese text

### Kanbun

You can adjust:

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

Meaning:

- `size`: font size of that annotation layer
- `shift.up`: move upward
- `shift.right`: move right
- `shift.down`: move downward
- `shift.left`: move left
- `side.gap`: distance between the base character area and the right-side annotation column
- `side.min_width`: minimum reserved width for right-side annotations

## 9. Allowed units

### Margins and body size

These must use physical units:

- `pt`
- `mm`
- `cm`
- `in`

Examples:

- `12pt`
- `3cm`
- `25mm`

### Kanbun sizes and shifts

These can use TeX dimensions such as:

- `pt`
- `mm`
- `cm`
- `in`
- `bp`
- `dd`
- `cc`
- `sp`
- `ex`
- `em`
- `zw`
- `zh`

Examples:

- `1pt`
- `0.35ex`
- `0.10zw`

## 10. Validation rules

The CLI rejects invalid combinations before building.

Important rules:

- `characters_per_line` must be an integer and at least `2`
- `lines_per_page` must be an integer and at least `1`
- `body_size` must be positive
- kanbun `size` values must be positive
- kanbun `shift` values must be nonnegative
- impossible layouts are rejected if they would require negative character spacing

A common failure is this:

- too many characters per line with too large a font size and unchanged margins

Example:

- `40` characters per line at `12pt` is intentionally rejected in the current test suite

## 11. Kanbun syntax in Markdown

The Markdown syntax is still:

```markdown
[Base]{f="furigana" o="okurigana" k="kaeriten"}
```

Example:

```markdown
[世]{f="yo" o="ni" k="ni"}[有]{f="a" o="ri" k="ichi"}
```

The current filter reads:

- `f` = furigana
- `o` = okurigana
- `k` = kaeriten

## 12. Recommended testing loop

When you want to tune one thing at a time:

1. Change one parameter.
2. Rebuild the PDF.
3. Compare the PDF visually.
4. If needed, inspect the generated TeX with `--emit-tex`.

Fast loop:

```powershell
ruby bin\jpmd build document.md -o out\document.pdf --emit-tex out\document.tex
```

## 13. Visual regression report

There is also a visual suite that renders multiple variations and converts the resulting PDFs to images.

Run it with:

```powershell
ruby scripts\run_visual_suite.rb
```

Open the generated report:

- [out/variation-suite/report.html](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/out/variation-suite/report.html)

This report includes:

- layout variations
- default kanbun baseline
- separate furigana / kaeriten / okurigana movement tests
- embedded rendered images for quick comparison

## 14. Good starting experiments

If you want a safe place to start, try these one at a time:

### Layout tests

- change `characters_per_line` from `30` to `28`
- change `lines_per_page` from `30` to `32`
- change `body_size` from `12pt` to `11pt`
- keep margins fixed and see how spacing is recalculated

### Kanbun tests

- raise furigana: `kanbun.furigana.shift.up: 1pt`
- move kaeriten right: `kanbun.kaeriten.shift.right: 1pt`
- move okurigana down: `kanbun.okurigana.shift.down: 1pt`
- enlarge furigana only: `kanbun.furigana.size: 8pt`
- enlarge okurigana only: `kanbun.okurigana.size: 8pt`

## 15. Typical commands

Default build:

```powershell
ruby bin\jpmd build document.md -o out\document.pdf --emit-tex out\document.tex
```

Build with alternate config:

```powershell
ruby bin\jpmd build document.md -o out\document-test.pdf --emit-tex out\document-test.tex --config jpmd.test.yml
```

Show CLI help:

```powershell
ruby bin\jpmd --help
```

## 16. Files worth editing

- Main content: [document.md](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/document.md)
- Project defaults: [jpmd.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/jpmd.yml)
- Kanbun TeX template: [templates/preamble.tex.erb](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/templates/preamble.tex.erb)
- Visual suite cases: [test/variation_suite.yml](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/test/variation_suite.yml)
- Visual suite runner: [scripts/run_visual_suite.rb](C:/Users/peter/Desktop/apps/parser/v2-gemini-partial/scripts/run_visual_suite.rb)

## 17. Notes

- This repo currently builds with `LuaLaTeX`, not `XeLaTeX`.
- Quote blocks, citations, footer formatting, and the current house style are preserved by the existing template/preamble pipeline.
- If a build fails, read the CLI error first; most parameter mistakes are caught before LaTeX runs.
