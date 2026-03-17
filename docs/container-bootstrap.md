# Exact Container Bootstrap Notes

This file records what was done during this Linux bring-up work.

The commands below are the machine/bootstrap commands that mattered for getting the branch running and producing a Linux PDF. They are written as copy-pasteable commands, not as a script.

## Container Baseline

The container was:

- Ubuntu 24.04.3 LTS
- working directory: `/root/kanbun-parser`
- user: `root`

## What Was Installed In This Session

### 1. Initial distro TeX packages

These were installed first to make the basic LuaLaTeX path usable and to get missing LaTeX packages during debugging:

```bash
apt-get update
apt-get install -y texlive-latex-extra
```

### 2. PDF comparison utilities

```bash
apt-get install -y poppler-utils
```

### 3. Image inspection support

```bash
apt-get install -y python3-pil
```

### 4. Exact font assets

These files were downloaded and then committed under `vendor/fonts/`.

```bash
mkdir -p /root/kanbun-parser/vendor/fonts
curl -L --fail -o /root/kanbun-parser/vendor/fonts/msmincho.ttc https://github.com/edubkendo/.dotfiles/raw/refs/heads/master/.fonts/msmincho.ttc
git clone --depth 1 https://github.com/misuchiru03/font-times-new-roman /tmp/font-times-new-roman
cp /tmp/font-times-new-roman/Times\ New\ Roman.ttf /root/kanbun-parser/vendor/fonts/times.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Bold.ttf /root/kanbun-parser/vendor/fonts/timesbd.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Italic.ttf /root/kanbun-parser/vendor/fonts/timesi.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Bold\ Italic.ttf /root/kanbun-parser/vendor/fonts/timesbi.ttf
```

### 5. TinyTeX 2026 exploratory install

This was installed during investigation to compare results with a newer TeX stack. It is not required for the final documented workflow.

```bash
curl -L --fail -o /tmp/install-unx.sh https://yihui.org/tinytex/install-unx.sh
sh /tmp/install-unx.sh
~/.TinyTeX/bin/*/tlmgr install jlreq luatexja titlesec fancyhdr caption collection-langjapanese
```

### 6. Final TeX Live 2025 install used for the current Linux output

This was the important one, because the checked-in reference PDF was produced by `LuaTeX-1.22.0`.

```bash
cat > /tmp/texlive2025.profile <<'EOF'
selected_scheme scheme-small
TEXDIR /root/texlive/2025
TEXMFCONFIG /root/.texlive2025/texmf-config
TEXMFHOME /root/.texlive2025/texmf-home
TEXMFLOCAL /root/texlive/texmf-local
TEXMFSYSCONFIG /root/texlive/2025/texmf-config
TEXMFSYSVAR /root/texlive/2025/texmf-var
TEXMFVAR /root/.texlive2025/texmf-var
binary_x86_64-linux 1
collection-basic 1
collection-latex 1
collection-latexrecommended 1
instopt_adjustpath 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
EOF
```

```bash
cd /tmp
curl -L --fail -o install-tl-2025.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/install-tl-unx.tar.gz
mkdir -p /tmp/install-tl-2025
tar -xzf install-tl-2025.tar.gz -C /tmp/install-tl-2025 --strip-components=1
/tmp/install-tl-2025/install-tl --profile /tmp/texlive2025.profile --repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final
```

```bash
/root/texlive/2025/bin/x86_64-linux/tlmgr install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

## Final Verification Commands Used

```bash
cd /root/kanbun-parser
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
LUALATEX_PATH=/root/texlive/2025/bin/x86_64-linux/lualatex ruby bin/jpmd build document.md -o out/document-linux.pdf --emit-tex out/document-linux.tex
pdfinfo out/document-linux.pdf
pdffonts out/document-linux.pdf
```

## Notes

- The branch now vendors the exact Windows font files under `vendor/fonts/`, so a separate Windows font directory is no longer required.
- `out/document-linux.pdf` is the Linux-built artifact checked into this branch.
- `out/document.pdf` remains the original reference artifact from the earlier workflow.
- The committed file `docs/texlive-2025-root.profile` contains the same TeX Live profile content used in the commands above, so future rebuilds do not need to recreate it manually.
