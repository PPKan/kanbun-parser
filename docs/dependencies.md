# Dependencies

This file lists the requirements needed to build the CLI output on Linux or Windows.

## Required Tools

Every supported machine needs:

```text
Ruby
Pandoc
LuaLaTeX
```

## Required TeX Release

Use:

```text
TeX Live 2025
LuaHBTeX 1.22.0
```

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

The committed TeX profile also enables:

```text
collection-basic
collection-latex
collection-latexrecommended
```

## Linux Package Baseline

On Ubuntu 24.04 or a similar Debian-family system:

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

## Font Requirements

Linux can use the vendored exact font files:

```text
vendor/fonts/msmincho.ttc
vendor/fonts/times.ttf
vendor/fonts/timesbd.ttf
vendor/fonts/timesbi.ttf
vendor/fonts/timesi.ttf
```

Windows should have these fonts installed in the OS:

```text
MS Mincho
Times New Roman
```

## Ruby Dependencies

No external gems are required.

The current Ruby code uses the standard library only:

```text
erb
fileutils
open3
optparse
pathname
rbconfig
tempfile
tmpdir
yaml
```

## Optional Diagnostic Tools

Useful but not required:

```text
mutool
ghostscript
TinyTeX 2026
Ubuntu texlive-latex-extra packages
```
