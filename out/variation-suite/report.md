# Visual Variation Suite

Generated at: 2026-03-19 06:06:26 +0000

- Total cases: `19`
- Passed: `19`
- Failed: `0`

## 18 Characters Per Column (`PASS`)

- Slug: `chars-18`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-18.yml`
- PDF: `out/variation-suite/pdfs/chars-18.pdf`
- TeX: `out/variation-suite/tex/chars-18.tex`
- Page count: `4`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 18
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/chars-18.pdf
```

### Representative Pages

![chars-18-1.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-18-1.png)

![chars-18-4.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-18-4.png)

## 24 Characters Per Column (`PASS`)

- Slug: `chars-24-default`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-24-default.yml`
- PDF: `out/variation-suite/pdfs/chars-24-default.pdf`
- TeX: `out/variation-suite/tex/chars-24-default.tex`
- Page count: `3`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 24
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/chars-24-default.pdf
```

### Representative Pages

![chars-24-default-1.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-24-default-1.png)

![chars-24-default-3.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-24-default-3.png)

## 32 Characters Per Column (`PASS`)

- Slug: `chars-32-dense`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-32-dense.yml`
- PDF: `out/variation-suite/pdfs/chars-32-dense.pdf`
- TeX: `out/variation-suite/tex/chars-32-dense.tex`
- Page count: `3`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 32
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/chars-32-dense.pdf
```

### Representative Pages

![chars-32-dense-1.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-32-dense-1.png)

![chars-32-dense-3.png](/workspace/kanbun-parser/out/variation-suite/pages/chars-32-dense-3.png)

## 48 Characters Per Column At 16pt (`PASS`)

- Slug: `chars-48-at-16pt-invalid`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `failure`
- Config: `out/variation-suite/configs/chars-48-at-16pt-invalid.yml`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 48
  font:
    body_size: 16pt
```

### Command Output

```text
Layout requires negative kanjiskip; reduce font size, widen the text block, or lower characters_per_line
```
## 9 Columns Per Page (`PASS`)

- Slug: `cols-9`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/cols-9.yml`
- PDF: `out/variation-suite/pdfs/cols-9.pdf`
- TeX: `out/variation-suite/tex/cols-9.tex`
- Page count: `4`

### Overrides

```yaml
---
layout:
  grid:
    lines_per_page: 9
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/cols-9.pdf
```

### Representative Pages

![cols-9-1.png](/workspace/kanbun-parser/out/variation-suite/pages/cols-9-1.png)

![cols-9-4.png](/workspace/kanbun-parser/out/variation-suite/pages/cols-9-4.png)

## 13 Columns Per Page (`PASS`)

- Slug: `cols-13`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/cols-13.yml`
- PDF: `out/variation-suite/pdfs/cols-13.pdf`
- TeX: `out/variation-suite/tex/cols-13.tex`
- Page count: `3`

### Overrides

```yaml
---
layout:
  grid:
    lines_per_page: 13
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/cols-13.pdf
```

### Representative Pages

![cols-13-1.png](/workspace/kanbun-parser/out/variation-suite/pages/cols-13-1.png)

![cols-13-3.png](/workspace/kanbun-parser/out/variation-suite/pages/cols-13-3.png)

## 12pt Body Text (`PASS`)

- Slug: `font-12pt`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/font-12pt.yml`
- PDF: `out/variation-suite/pdfs/font-12pt.pdf`
- TeX: `out/variation-suite/tex/font-12pt.tex`
- Page count: `3`

### Overrides

```yaml
---
layout:
  font:
    body_size: 12pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/font-12pt.pdf
```

### Representative Pages

![font-12pt-1.png](/workspace/kanbun-parser/out/variation-suite/pages/font-12pt-1.png)

![font-12pt-3.png](/workspace/kanbun-parser/out/variation-suite/pages/font-12pt-3.png)

## 16pt Body Text (`PASS`)

- Slug: `font-16pt`
- Focus: layout
- Input: `examples/linear-kundoku.md`
- Expected: `success`
- Config: `out/variation-suite/configs/font-16pt.yml`
- PDF: `out/variation-suite/pdfs/font-16pt.pdf`
- TeX: `out/variation-suite/tex/font-16pt.tex`
- Page count: `3`

### Overrides

```yaml
---
layout:
  font:
    body_size: 16pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/font-16pt.pdf
```

### Representative Pages

![font-16pt-1.png](/workspace/kanbun-parser/out/variation-suite/pages/font-16pt-1.png)

![font-16pt-3.png](/workspace/kanbun-parser/out/variation-suite/pages/font-16pt-3.png)

## Default Kanbun Layout (`PASS`)

- Slug: `kanbun-default`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-default.yml`
- PDF: `out/variation-suite/pdfs/kanbun-default.pdf`
- TeX: `out/variation-suite/tex/kanbun-default.tex`
- Page count: `2`

### Overrides

```yaml
--- {}
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kanbun-default.pdf
```

### Representative Pages

![kanbun-default-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kanbun-default-1.png)

## Large Kanbun Annotations (`PASS`)

- Slug: `kanbun-big-all`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-big-all.yml`
- PDF: `out/variation-suite/pdfs/kanbun-big-all.pdf`
- TeX: `out/variation-suite/tex/kanbun-big-all.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    size: 11pt
    shift:
      up: 1pt
      right: 1pt
      down: 0pt
      left: 0pt
  kaeriten:
    size: 10pt
    shift:
      up: 1pt
      right: 1pt
      down: 0pt
      left: 0pt
  okurigana:
    size: 10pt
    shift:
      up: 0pt
      right: 1pt
      down: 1pt
      left: 0pt
  side:
    min_width: 0.55zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kanbun-big-all.pdf
```

### Representative Pages

![kanbun-big-all-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kanbun-big-all-1.png)

## Furigana Shifted Up And Right (`PASS`)

- Slug: `furigana-up-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/furigana-up-right.yml`
- PDF: `out/variation-suite/pdfs/furigana-up-right.pdf`
- TeX: `out/variation-suite/tex/furigana-up-right.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    size: 10pt
    shift:
      up: 2pt
      right: 3pt
      down: 0pt
      left: 0pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/furigana-up-right.pdf
```

### Representative Pages

![furigana-up-right-1.png](/workspace/kanbun-parser/out/variation-suite/pages/furigana-up-right-1.png)

## Furigana Shifted Left And Down (`PASS`)

- Slug: `furigana-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/furigana-left-down.yml`
- PDF: `out/variation-suite/pdfs/furigana-left-down.pdf`
- TeX: `out/variation-suite/tex/furigana-left-down.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    size: 10pt
    shift:
      up: 0pt
      right: 0pt
      down: 1.5pt
      left: 2pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/furigana-left-down.pdf
```

### Representative Pages

![furigana-left-down-1.png](/workspace/kanbun-parser/out/variation-suite/pages/furigana-left-down-1.png)

## Kaeriten Shifted Up And Right (`PASS`)

- Slug: `kaeriten-up-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kaeriten-up-right.yml`
- PDF: `out/variation-suite/pdfs/kaeriten-up-right.pdf`
- TeX: `out/variation-suite/tex/kaeriten-up-right.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  kaeriten:
    size: 9pt
    shift:
      up: 2pt
      right: 3pt
      down: 0pt
      left: 0pt
  side:
    min_width: 0.55zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kaeriten-up-right.pdf
```

### Representative Pages

![kaeriten-up-right-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kaeriten-up-right-1.png)

## Kaeriten Shifted Left And Down (`PASS`)

- Slug: `kaeriten-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kaeriten-left-down.yml`
- PDF: `out/variation-suite/pdfs/kaeriten-left-down.pdf`
- TeX: `out/variation-suite/tex/kaeriten-left-down.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  kaeriten:
    size: 9pt
    shift:
      up: 0pt
      right: 0pt
      down: 1.5pt
      left: 2pt
  side:
    min_width: 0.55zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kaeriten-left-down.pdf
```

### Representative Pages

![kaeriten-left-down-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kaeriten-left-down-1.png)

## Okurigana Shifted Down And Right (`PASS`)

- Slug: `okurigana-down-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/okurigana-down-right.yml`
- PDF: `out/variation-suite/pdfs/okurigana-down-right.pdf`
- TeX: `out/variation-suite/tex/okurigana-down-right.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  okurigana:
    size: 10pt
    shift:
      up: 0pt
      right: 3pt
      down: 2pt
      left: 0pt
  side:
    min_width: 0.55zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/okurigana-down-right.pdf
```

### Representative Pages

![okurigana-down-right-1.png](/workspace/kanbun-parser/out/variation-suite/pages/okurigana-down-right-1.png)

## Okurigana Shifted Up And Left (`PASS`)

- Slug: `okurigana-up-left`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/okurigana-up-left.yml`
- PDF: `out/variation-suite/pdfs/okurigana-up-left.pdf`
- TeX: `out/variation-suite/tex/okurigana-up-left.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  okurigana:
    size: 10pt
    shift:
      up: 1.5pt
      right: 0pt
      down: 0pt
      left: 2pt
  side:
    min_width: 0.55zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/okurigana-up-left.pdf
```

### Representative Pages

![okurigana-up-left-1.png](/workspace/kanbun-parser/out/variation-suite/pages/okurigana-up-left-1.png)

## Kanbun Shifted Left And Down (`PASS`)

- Slug: `kanbun-shift-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-shift-left-down.yml`
- PDF: `out/variation-suite/pdfs/kanbun-shift-left-down.pdf`
- TeX: `out/variation-suite/tex/kanbun-shift-left-down.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    shift:
      up: 0pt
      right: 0pt
      down: 1pt
      left: 2pt
  kaeriten:
    shift:
      up: 0pt
      right: 0pt
      down: 1.5pt
      left: 2pt
  okurigana:
    shift:
      up: 0pt
      right: 0pt
      down: 2pt
      left: 2pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kanbun-shift-left-down.pdf
```

### Representative Pages

![kanbun-shift-left-down-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kanbun-shift-left-down-1.png)

## Kanbun Shifted Right (`PASS`)

- Slug: `kanbun-shift-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-shift-right.yml`
- PDF: `out/variation-suite/pdfs/kanbun-shift-right.pdf`
- TeX: `out/variation-suite/tex/kanbun-shift-right.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    shift:
      up: 0pt
      right: 3pt
      down: 0pt
      left: 0pt
  kaeriten:
    shift:
      up: 0pt
      right: 3pt
      down: 0.5pt
      left: 0pt
  okurigana:
    shift:
      up: 0pt
      right: 3pt
      down: 1pt
      left: 0pt
  side:
    min_width: 0.6zw
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kanbun-shift-right.pdf
```

### Representative Pages

![kanbun-shift-right-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kanbun-shift-right-1.png)

## Kanbun Mixed Sizes (`PASS`)

- Slug: `kanbun-mixed-sizes`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-mixed-sizes.yml`
- PDF: `out/variation-suite/pdfs/kanbun-mixed-sizes.pdf`
- TeX: `out/variation-suite/tex/kanbun-mixed-sizes.tex`
- Page count: `2`

### Overrides

```yaml
---
kanbun:
  furigana:
    size: 9pt
  kaeriten:
    size: 6pt
  okurigana:
    size: 12pt
    shift:
      up: 0pt
      right: 1pt
      down: 1pt
      left: 0pt
```

### Command Output

```text
Wrote /workspace/kanbun-parser/out/variation-suite/pdfs/kanbun-mixed-sizes.pdf
```

### Representative Pages

![kanbun-mixed-sizes-1.png](/workspace/kanbun-parser/out/variation-suite/pages/kanbun-mixed-sizes-1.png)
