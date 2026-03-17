# Kanbun Parser

This branch contains the Linux build work for the `parameterized-layout` pipeline.

The important outputs on this branch are:

- `out/document.pdf`: the checked-in reference PDF from the original workflow
- `out/document-linux.pdf`: the PDF rebuilt on Linux on this branch

The Linux build keeps the same font choices:

- `Times New Roman`
- `MS Mincho`

The branch also vendors the exact font files under `vendor/fonts/` so the build does not depend on a Windows font directory.

## Quick Start On A Clean Ubuntu 24.04 Container

All commands below are copy-pasteable. In this container they were run as `root`. If you are not `root`, prefix package-management commands with `sudo`.

### 1. Install base packages

```bash
apt-get update
apt-get install -y ca-certificates curl fontconfig git pandoc perl poppler-utils python3-pil ruby tar xz-utils
```

### 2. Clone the repository and check out this branch

```bash
cd /root
git clone https://github.com/PPKan/kanbun-parser.git
cd kanbun-parser
git checkout linux-parameterized-layout
```

### 3. Install TeX Live 2025

The checked-in reference PDF was produced by `LuaTeX-1.22.0`, so this setup uses the frozen TeX Live 2025 archive instead of the Ubuntu TeX packages. The profile file used for the local install is already committed at `docs/texlive-2025-root.profile`.

```bash
cd /tmp
curl -L --fail -o install-tl-2025.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/install-tl-unx.tar.gz
mkdir -p /tmp/install-tl-2025
tar -xzf install-tl-2025.tar.gz -C /tmp/install-tl-2025 --strip-components=1
/tmp/install-tl-2025/install-tl --profile /root/kanbun-parser/docs/texlive-2025-root.profile --repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final
```

### 4. Install the TeX packages required by this repo

```bash
/root/texlive/2025/bin/x86_64-linux/tlmgr install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

### 5. Return to the repo and verify the toolchain

```bash
cd /root/kanbun-parser
ruby -v
pandoc --version | head -n 2
/root/texlive/2025/bin/x86_64-linux/lualatex --version | head -n 2
```

### 6. Run the tests

```bash
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
```

### 7. Build the PDF

```bash
LUALATEX_PATH=/root/texlive/2025/bin/x86_64-linux/lualatex ruby bin/jpmd build document.md -o out/document-linux.pdf --emit-tex out/document-linux.tex
```

### 8. Optional checks

```bash
pdfinfo out/document-linux.pdf
pdffonts out/document-linux.pdf
```

## Files To Read

- `docs/container-bootstrap.md`: exact container initialization steps used during this work
- `docs/dependencies.md`: dependency inventory
- `docs/compile-and-adjust.md`: layout tuning notes
- `Dockerfile`: reproducible image build

## Docker

Build the image:

```bash
docker build -t kanbun-parser:linux-parameterized-layout .
```

Open a shell in the container:

```bash
docker run --rm -it -v "$PWD:/workspace" kanbun-parser:linux-parameterized-layout
```

Build the PDF inside Docker:

```bash
docker run --rm -it -v "$PWD:/workspace" kanbun-parser:linux-parameterized-layout sh -lc 'ruby -Itest test/jpmd_config_test.rb && ruby -Itest test/jpmd_compiler_test.rb && ruby bin/jpmd build document.md -o out/document-linux.pdf --emit-tex out/document-linux.tex'
```
