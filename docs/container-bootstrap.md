# Historical Linux Container Bootstrap

This file preserves the exact Linux bring-up notes from the TeX Live 2025 stabilization work.

Use `README.md` or `AGENTS.md` for normal setup. Use this file only when you want the older container-oriented reproduction path.

## Baseline

- Ubuntu 24.04.3 LTS
- working directory: `/root/kanbun-parser`
- user: `root`

## Packages Installed During The Bring-Up

```bash
apt-get update
apt-get install -y texlive-latex-extra poppler-utils python3-pil
```

## Exact Font Asset Acquisition

```bash
mkdir -p /root/kanbun-parser/vendor/fonts
curl -L --fail -o /root/kanbun-parser/vendor/fonts/msmincho.ttc https://github.com/edubkendo/.dotfiles/raw/refs/heads/master/.fonts/msmincho.ttc
git clone --depth 1 https://github.com/misuchiru03/font-times-new-roman /tmp/font-times-new-roman
cp /tmp/font-times-new-roman/Times\ New\ Roman.ttf /root/kanbun-parser/vendor/fonts/times.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Bold.ttf /root/kanbun-parser/vendor/fonts/timesbd.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Italic.ttf /root/kanbun-parser/vendor/fonts/timesi.ttf
cp /tmp/font-times-new-roman/Times\ New\ Roman\ -\ Bold\ Italic.ttf /root/kanbun-parser/vendor/fonts/timesbi.ttf
```

## Exact TeX Live 2025 Install

The committed profile file is `docs/texlive-2025-root.profile`.

```bash
cd /tmp
curl -L --fail -o install-tl-2025.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/install-tl-unx.tar.gz
mkdir -p /tmp/install-tl-2025
tar -xzf install-tl-2025.tar.gz -C /tmp/install-tl-2025 --strip-components=1
/tmp/install-tl-2025/install-tl --profile /root/kanbun-parser/docs/texlive-2025-root.profile --repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final
/root/texlive/2025/bin/x86_64-linux/tlmgr install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

## Verification Commands Used

```bash
cd /root/kanbun-parser
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
LUALATEX_PATH=/root/texlive/2025/bin/x86_64-linux/lualatex ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --emit-tex out/academic-paper.tex
pdfinfo out/academic-paper.pdf
pdffonts out/academic-paper.pdf
```
