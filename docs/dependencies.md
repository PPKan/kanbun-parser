# Dependencies

This file lists the dependencies needed to build the PDF on this branch.

## Required OS Packages

Install these packages on Ubuntu 24.04:

```text
ca-certificates
curl
fontconfig
git
pandoc
perl
poppler-utils
python3-pil
ruby
tar
xz-utils
```

## Required TeX Live Release

Use:

```text
TeX Live 2025
LuaHBTeX 1.22.0
```

The branch was debugged against other TeX versions, but the reference PDF was produced with `LuaTeX-1.22.0`, so the documented reproducible path uses TeX Live 2025.

## Required TeX Packages

Install these into the TeX Live 2025 tree:

```text
jlreq
luatexja
titlesec
haranoaji
lualatex-math
selnolig
```

The TeX Live 2025 profile used in this repo also enables:

```text
collection-basic
collection-latex
collection-latexrecommended
```

## Vendored Font Assets

The repo includes the font files required to keep the original font choices unchanged:

```text
vendor/fonts/msmincho.ttc
vendor/fonts/times.ttf
vendor/fonts/timesbd.ttf
vendor/fonts/timesbi.ttf
vendor/fonts/timesi.ttf
```

Those files are used to satisfy:

```text
MS Mincho
Times New Roman
```

## Ruby Dependencies

No external gems are required.

The Ruby code uses only the standard library:

```text
erb
fileutils
open3
optparse
pathname
rbconfig
tmpdir
yaml
```

## Optional Diagnostic Tools

These were useful during comparison/debugging but are not required for the main build:

```text
mutool
ghostscript
TinyTeX 2026
Ubuntu texlive-latex-extra packages
```
