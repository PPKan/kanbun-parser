# kanbun-parser

Languages: English (default) | [日本語](README.ja.md) | [繁體中文（台灣）](README.zh-Hant-TW.md)

`kanbun-parser` is a small reference repository for turning Japanese Markdown into PDF with kanbun annotations. The current `main` workflow is direct: Pandoc reads Markdown, `filter.lua` converts kanbun spans into TeX macros, and LuaLaTeX renders the final document.

## What This Repository Contains

- [document.md](document.md): full sample paper with citations, quote blocks, and kanbun markup.
- [document.pdf](document.pdf): tracked reference output for the full sample.
- [filter.lua](filter.lua): Pandoc Lua filter that maps bracketed spans to `\kanbun{...}{...}{...}{...}`.
- [preamble.tex](preamble.tex): Japanese layout and kanbun macro definitions.
- [template.tex](template.tex): Pandoc LaTeX template for the document build.
- [references/](references/): sample bibliography data and CSL style.
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): smallest sample for kanbun-only compilation.
- [docs/images/readme-final-result.png](docs/images/readme-final-result.png): preview image used below.

## Quick Start

Prerequisites:

- `pandoc`
- `lualatex`
- TeX Live or MiKTeX packages including `jlreq`, `luatexja-fontspec`, `luatexja-ruby`, `titlesec`, `fancyhdr`, `caption`, `longtable`, `booktabs`, and `etoolbox`
- `Times New Roman`
- `MS Mincho`

Build from the repository root. The sample on `main` expects `Times New Roman` and `MS Mincho` to be available to LuaLaTeX.

**Linux**

```bash
mkdir -p out
pandoc document.md \
  -f markdown+bracketed_spans \
  --standalone \
  --citeproc \
  --template template.tex \
  --lua-filter filter.lua \
  -t latex \
  -o out/document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/document.tex
```

**Windows PowerShell**

```powershell
New-Item -ItemType Directory -Path out -Force | Out-Null
pandoc .\document.md `
  -f markdown+bracketed_spans `
  --standalone `
  --citeproc `
  --template .\template.tex `
  --lua-filter .\filter.lua `
  -t latex `
  -o .\out\document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out .\out\document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out .\out\document.tex
```

## If You Only Want Kanbun

Use [examples/minimal-kanbun.md](examples/minimal-kanbun.md) when you only want to test kanbun markup without citations or a full paper layout.

```md
[世]{f="よ" o="ニ" k="二"}[有]{f="あ" o="リ" k="一"}[伯]{f="はく"}[樂]{f="らく"}。
```

Compile it with the same pipeline:

```bash
mkdir -p out
pandoc examples/minimal-kanbun.md \
  -f markdown+bracketed_spans \
  --standalone \
  --template template.tex \
  --lua-filter filter.lua \
  -t latex \
  -o out/minimal-kanbun.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/minimal-kanbun.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/minimal-kanbun.tex
```

## Expected Output

Pandoc is silent on success. The last LuaLaTeX pass should end with a line similar to:

```text
Output written on out/document.pdf (6 pages, ... bytes).
```

For the kanbun-only sample, the matching line is:

```text
Output written on out/minimal-kanbun.pdf (... pages, ... bytes).
```

You should then have:

- `out/document.tex`
- `out/document.pdf`
- `out/minimal-kanbun.tex`
- `out/minimal-kanbun.pdf`

## Final Result Demo

The preview below comes from the tracked [document.pdf](document.pdf) and shows the output style this repository targets on `main`.

![Final result demo](docs/images/readme-final-result.png)

Reference PDF: [document.pdf](document.pdf)

## Important Files

- [document.md](document.md): end-to-end sample with bibliography and kanbun markup.
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): fastest file to copy when testing kanbun only.
- [filter.lua](filter.lua): bracketed-span to TeX conversion.
- [preamble.tex](preamble.tex): layout, fonts, and kanbun placement macros.
- [template.tex](template.tex): Pandoc template used for the TeX build.

## Notes

- Run commands from the repository root so `\input{preamble.tex}` resolves correctly.
- Missing fonts are the most common failure on Linux. Install or register `Times New Roman` and `MS Mincho` before compiling.
- Minor line breaking can vary across TeX Live versions even when the source is unchanged.
- `out/` is generated working output and can be deleted any time.
