# Visual Variation Suite

Generated at: 2026-03-16 13:50:35 +0000

- Total cases: `19`
- Passed: `19`
- Failed: `0`

## 20 Characters Per Line (`PASS`)

- Slug: `chars-20`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-20.yml`
- PDF: `out/variation-suite/pdfs/chars-20.pdf`
- TeX: `out/variation-suite/tex/chars-20.tex`
- Page count: `7`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 20
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/chars-20.pdf
```

### Representative Pages

![chars-20-1.png](/root/kanbun-parser/out/variation-suite/pages/chars-20-1.png)

![chars-20-7.png](/root/kanbun-parser/out/variation-suite/pages/chars-20-7.png)

## 30 Characters Per Line (`PASS`)

- Slug: `chars-30-default`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-30-default.yml`
- PDF: `out/variation-suite/pdfs/chars-30-default.pdf`
- TeX: `out/variation-suite/tex/chars-30-default.tex`
- Page count: `6`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 30
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/chars-30-default.pdf
```

### Representative Pages

![chars-30-default-1.png](/root/kanbun-parser/out/variation-suite/pages/chars-30-default-1.png)

![chars-30-default-6.png](/root/kanbun-parser/out/variation-suite/pages/chars-30-default-6.png)

## 40 Characters Per Line At 12pt (`PASS`)

- Slug: `chars-40-invalid`
- Focus: layout
- Input: `document.md`
- Expected: `failure`
- Config: `out/variation-suite/configs/chars-40-invalid.yml`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 40
```

### Command Output

```text
Layout requires negative kanjiskip; reduce font size, widen the text block, or lower characters_per_line
```
## 40 Characters Per Line At 10pt (`PASS`)

- Slug: `chars-40-at-10pt`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/chars-40-at-10pt.yml`
- PDF: `out/variation-suite/pdfs/chars-40-at-10pt.pdf`
- TeX: `out/variation-suite/tex/chars-40-at-10pt.tex`
- Page count: `6`

### Overrides

```yaml
---
layout:
  grid:
    characters_per_line: 40
  font:
    body_size: 10pt
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/chars-40-at-10pt.pdf
```

### Representative Pages

![chars-40-at-10pt-1.png](/root/kanbun-parser/out/variation-suite/pages/chars-40-at-10pt-1.png)

![chars-40-at-10pt-6.png](/root/kanbun-parser/out/variation-suite/pages/chars-40-at-10pt-6.png)

## 20 Lines Per Page (`PASS`)

- Slug: `lines-20`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/lines-20.yml`
- PDF: `out/variation-suite/pdfs/lines-20.pdf`
- TeX: `out/variation-suite/tex/lines-20.tex`
- Page count: `8`

### Overrides

```yaml
---
layout:
  grid:
    lines_per_page: 20
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/lines-20.pdf
```

### Representative Pages

![lines-20-1.png](/root/kanbun-parser/out/variation-suite/pages/lines-20-1.png)

![lines-20-8.png](/root/kanbun-parser/out/variation-suite/pages/lines-20-8.png)

## 40 Lines Per Page (`PASS`)

- Slug: `lines-40`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/lines-40.yml`
- PDF: `out/variation-suite/pdfs/lines-40.pdf`
- TeX: `out/variation-suite/tex/lines-40.tex`
- Page count: `5`

### Overrides

```yaml
---
layout:
  grid:
    lines_per_page: 40
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/lines-40.pdf
```

### Representative Pages

![lines-40-1.png](/root/kanbun-parser/out/variation-suite/pages/lines-40-1.png)

![lines-40-5.png](/root/kanbun-parser/out/variation-suite/pages/lines-40-5.png)

## 10pt Body Text (`PASS`)

- Slug: `font-10pt`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/font-10pt.yml`
- PDF: `out/variation-suite/pdfs/font-10pt.pdf`
- TeX: `out/variation-suite/tex/font-10pt.tex`
- Page count: `6`

### Overrides

```yaml
---
layout:
  font:
    body_size: 10pt
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/font-10pt.pdf
```

### Representative Pages

![font-10pt-1.png](/root/kanbun-parser/out/variation-suite/pages/font-10pt-1.png)

![font-10pt-6.png](/root/kanbun-parser/out/variation-suite/pages/font-10pt-6.png)

## 14pt Body Text (`PASS`)

- Slug: `font-14pt`
- Focus: layout
- Input: `document.md`
- Expected: `success`
- Config: `out/variation-suite/configs/font-14pt.yml`
- PDF: `out/variation-suite/pdfs/font-14pt.pdf`
- TeX: `out/variation-suite/tex/font-14pt.tex`
- Page count: `6`

### Overrides

```yaml
---
layout:
  font:
    body_size: 14pt
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/font-14pt.pdf
```

### Representative Pages

![font-14pt-1.png](/root/kanbun-parser/out/variation-suite/pages/font-14pt-1.png)

![font-14pt-6.png](/root/kanbun-parser/out/variation-suite/pages/font-14pt-6.png)

## Default Kanbun Layout (`PASS`)

- Slug: `kanbun-default`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-default.yml`
- PDF: `out/variation-suite/pdfs/kanbun-default.pdf`
- TeX: `out/variation-suite/tex/kanbun-default.tex`
- Page count: `1`

### Overrides

```yaml
--- {}
```

### Command Output

```text
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kanbun-default.pdf
```

### Representative Pages

![kanbun-default-1.png](/root/kanbun-parser/out/variation-suite/pages/kanbun-default-1.png)

## Large Kanbun Annotations (`PASS`)

- Slug: `kanbun-big-all`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-big-all.yml`
- PDF: `out/variation-suite/pdfs/kanbun-big-all.pdf`
- TeX: `out/variation-suite/tex/kanbun-big-all.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kanbun-big-all.pdf
```

### Representative Pages

![kanbun-big-all-1.png](/root/kanbun-parser/out/variation-suite/pages/kanbun-big-all-1.png)

## Furigana Shifted Up And Right (`PASS`)

- Slug: `furigana-up-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/furigana-up-right.yml`
- PDF: `out/variation-suite/pdfs/furigana-up-right.pdf`
- TeX: `out/variation-suite/tex/furigana-up-right.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/furigana-up-right.pdf
```

### Representative Pages

![furigana-up-right-1.png](/root/kanbun-parser/out/variation-suite/pages/furigana-up-right-1.png)

## Furigana Shifted Left And Down (`PASS`)

- Slug: `furigana-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/furigana-left-down.yml`
- PDF: `out/variation-suite/pdfs/furigana-left-down.pdf`
- TeX: `out/variation-suite/tex/furigana-left-down.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/furigana-left-down.pdf
```

### Representative Pages

![furigana-left-down-1.png](/root/kanbun-parser/out/variation-suite/pages/furigana-left-down-1.png)

## Kaeriten Shifted Up And Right (`PASS`)

- Slug: `kaeriten-up-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kaeriten-up-right.yml`
- PDF: `out/variation-suite/pdfs/kaeriten-up-right.pdf`
- TeX: `out/variation-suite/tex/kaeriten-up-right.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kaeriten-up-right.pdf
```

### Representative Pages

![kaeriten-up-right-1.png](/root/kanbun-parser/out/variation-suite/pages/kaeriten-up-right-1.png)

## Kaeriten Shifted Left And Down (`PASS`)

- Slug: `kaeriten-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kaeriten-left-down.yml`
- PDF: `out/variation-suite/pdfs/kaeriten-left-down.pdf`
- TeX: `out/variation-suite/tex/kaeriten-left-down.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kaeriten-left-down.pdf
```

### Representative Pages

![kaeriten-left-down-1.png](/root/kanbun-parser/out/variation-suite/pages/kaeriten-left-down-1.png)

## Okurigana Shifted Down And Right (`PASS`)

- Slug: `okurigana-down-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/okurigana-down-right.yml`
- PDF: `out/variation-suite/pdfs/okurigana-down-right.pdf`
- TeX: `out/variation-suite/tex/okurigana-down-right.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/okurigana-down-right.pdf
```

### Representative Pages

![okurigana-down-right-1.png](/root/kanbun-parser/out/variation-suite/pages/okurigana-down-right-1.png)

## Okurigana Shifted Up And Left (`PASS`)

- Slug: `okurigana-up-left`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/okurigana-up-left.yml`
- PDF: `out/variation-suite/pdfs/okurigana-up-left.pdf`
- TeX: `out/variation-suite/tex/okurigana-up-left.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/okurigana-up-left.pdf
```

### Representative Pages

![okurigana-up-left-1.png](/root/kanbun-parser/out/variation-suite/pages/okurigana-up-left-1.png)

## Kanbun Shifted Left And Down (`PASS`)

- Slug: `kanbun-shift-left-down`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-shift-left-down.yml`
- PDF: `out/variation-suite/pdfs/kanbun-shift-left-down.pdf`
- TeX: `out/variation-suite/tex/kanbun-shift-left-down.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kanbun-shift-left-down.pdf
```

### Representative Pages

![kanbun-shift-left-down-1.png](/root/kanbun-parser/out/variation-suite/pages/kanbun-shift-left-down-1.png)

## Kanbun Shifted Right (`PASS`)

- Slug: `kanbun-shift-right`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-shift-right.yml`
- PDF: `out/variation-suite/pdfs/kanbun-shift-right.pdf`
- TeX: `out/variation-suite/tex/kanbun-shift-right.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kanbun-shift-right.pdf
```

### Representative Pages

![kanbun-shift-right-1.png](/root/kanbun-parser/out/variation-suite/pages/kanbun-shift-right-1.png)

## Kanbun Mixed Sizes (`PASS`)

- Slug: `kanbun-mixed-sizes`
- Focus: kanbun
- Input: `test/fixtures/kanbun-visual.md`
- Expected: `success`
- Config: `out/variation-suite/configs/kanbun-mixed-sizes.yml`
- PDF: `out/variation-suite/pdfs/kanbun-mixed-sizes.pdf`
- TeX: `out/variation-suite/tex/kanbun-mixed-sizes.tex`
- Page count: `1`

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
Wrote /root/kanbun-parser/out/variation-suite/pdfs/kanbun-mixed-sizes.pdf
```

### Representative Pages

![kanbun-mixed-sizes-1.png](/root/kanbun-parser/out/variation-suite/pages/kanbun-mixed-sizes-1.png)
