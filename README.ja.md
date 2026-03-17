# Kanbun Parser

言語: [English](README.md) | 日本語 | [繁體中文](README.zh-Hant-TW.md)

Kanbun Parser は、Markdown を Pandoc と LuaLaTeX 経由で PDF に変換する Ruby 製 CLI です。漢文の注記として次を扱えます。

- 振り仮名
- 送り仮名
- 返り点

主な用途は二つです。

- Markdown で書いた和文学術文書を PDF に組版する
- 漢文だけをすぐに試し組みする

## 主な構成

- `bin/jpmd` / `bin/jpmd.cmd`: CLI エントリポイント
- `jpmd.yml`: 既定レイアウト設定
- `examples/academic-paper.md`: 論文形式のサンプル
- `examples/minimal-kanbun.md`: 漢文だけを試す最小サンプル
- `examples/scripts/`: Linux / Windows 用サンプルスクリプト
- `filter.lua`: 漢文注記を TeX に変換する Pandoc フィルタ
- `templates/preamble.tex.erb`: 組版と漢文注記の TeX テンプレート
- `scripts/run_visual_suite.rb`: `out/variation-suite/report.html` を生成
- `AGENTS.md`: AI エージェント向けセットアップ文書

## どのサンプルから始めるか

完成した Markdown 文書を持っている場合は `examples/academic-paper.md` を基準にしてください。

漢文だけを組みたい場合は `examples/minimal-kanbun.md` を使ってください。最小例は漢文記法だけに絞っています。

```markdown
[世]{o="ニ"}[有]{o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}。
```

## Linux セットアップ

Debian / Ubuntu 系を前提にしています。Linux では `vendor/fonts/` に同梱したフォントを自動利用できます。

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl fontconfig git pandoc perl poppler-utils python3-pil ruby tar xz-utils
```

TeX Live 2025 を導入し、次のパッケージを入れてください。

```bash
/path/to/texlive/2025/bin/x86_64-linux/tlmgr install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

その後、リポジトリで検証とビルドを行います。

```bash
git clone https://github.com/PPKan/kanbun-parser.git
cd kanbun-parser
export LUALATEX_PATH=/path/to/texlive/2025/bin/x86_64-linux/lualatex
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --emit-tex out/academic-paper.tex
```

サンプルスクリプトも使えます。

```bash
bash examples/scripts/build-linux.sh
```

## Windows セットアップ

PowerShell を使います。先に次をインストールし、`PATH` を通してください。

- Git
- Ruby
- Pandoc
- TeX Live 2025

Windows では次のフォントが OS にインストールされている必要があります。

- Times New Roman
- MS Mincho

TeX パッケージを追加します。

```powershell
C:\texlive\2025\bin\windows\tlmgr.bat install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

続けて検証とビルドを行います。

```powershell
git clone https://github.com/PPKan/kanbun-parser.git
cd kanbun-parser
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
.\bin\jpmd.cmd build .\examples\minimal-kanbun.md -o .\out\minimal-kanbun.pdf --emit-tex .\out\minimal-kanbun.tex
.\bin\jpmd.cmd build .\examples\academic-paper.md -o .\out\academic-paper.pdf --emit-tex .\out\academic-paper.tex
```

PowerShell 用サンプルスクリプト:

```powershell
powershell -ExecutionPolicy Bypass -File .\examples\scripts\build-windows.ps1
```

## Visual Suite

```bash
ruby scripts/run_visual_suite.rb
```

生成物:

```text
out/variation-suite/report.html
```

## 補足

- `out/` は生成物用ディレクトリであり、Git 管理対象ではありません。
- 調整項目は `jpmd.yml` と各 Markdown の `jpmd:` frontmatter で上書きできます。
- 詳細は `docs/dependencies.md`、`docs/compile-and-adjust.md`、`docs/container-bootstrap.md` を参照してください。
