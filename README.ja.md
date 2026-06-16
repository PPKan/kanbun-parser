# Kanbun Parser

言語: [English](README.md) | 日本語 | [繁體中文（台灣）](README.zh-Hant-TW.md)

Kanbun Parser は、Markdown を Pandoc と LuaLaTeX 経由で PDF に変換する Ruby 製 CLI です。漢文の注記として次を扱えます。

- 振り仮名
- 送り仮名
- 返り点

主な用途は三つです。

- Markdown で書いた和文学術文書を PDF に組版する
- 漢文だけをすぐに試し組みする

## 主な構成

- `bin/jpmd` / `bin/jpmd.cmd`: CLI エントリポイント
- `jpmd.yml`: 既定レイアウト設定
- `examples/academic-paper.md`: 論文形式のサンプル
- `examples/minimal-kanbun.md`: 漢文だけを試す最小サンプル
- `examples/two-file-manuscript.md`: 参考文献設定を含むサンプル
- `examples/scripts/`: Linux / Windows 用サンプルスクリプト
- `filter.lua`: 漢文注記を TeX に変換する Pandoc フィルタ
- `templates/preamble.tex.erb`: 組版と漢文注記の TeX テンプレート
- `scripts/run_visual_suite.rb`: `out/variation-suite/report.html` を生成
- `docs/images/readme-final-result.png`: この README で使う組版結果のプレビュー画像
- `AGENTS.md`: AI エージェント向けセットアップ文書

## どのサンプルから始めるか

完成した横組文書を持っている場合は、`examples/academic-paper.md` が基準サンプルです。

漢文だけを組みたい場合は `examples/minimal-kanbun.md` を使ってください。最小例は漢文記法だけに絞っています。

```markdown
[世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="二"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば" k="一"}。
```

文献を使う場合、もっとも簡単な方法はビルド時に CLI で bibliography を渡すことです。

```bash
ruby bin/jpmd build manuscript.md \
  --bibliography library.json \
  --output out/manuscript.pdf \
  --suppress-bibliography
```

PDF 末尾に参考文献を出したい場合は `--render-bibliography` を使います。CSL を指定したい場合は `--csl custom.csl` を追加できます。指定しない場合は、プロジェクト既定の `references/word-japanese-note.csl` が使われます。

原稿自体に文献設定を持たせたい場合は、`bibliography:` と必要なら `csl:` を Markdown frontmatter に書くこともできます。`examples/two-file-manuscript.md` はその形式の例です。

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
ruby bin/jpmd build examples/minimal-kanbun.md
ruby bin/jpmd build examples/two-file-manuscript.md
```

想定される出力:

```text
Wrote /path/to/kanbun-parser/out/minimal-kanbun.pdf
```

生成されるファイル:

- `out/minimal-kanbun.pdf`: 漢文だけのサンプル PDF
- `out/minimal-kanbun.tex`: 確認用に出力された TeX
- `out/two-file-manuscript.pdf`: 参考文献付き原稿サンプルの PDF
- `out/two-file-manuscript.tex`: 参考文献付き原稿サンプルの TeX

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
.\bin\jpmd.cmd build .\examples\minimal-kanbun.md
.\bin\jpmd.cmd build .\examples\two-file-manuscript.md
```

PowerShell 用サンプルスクリプト:

```powershell
powershell -ExecutionPolicy Bypass -File .\examples\scripts\build-windows.ps1
```

## Visual Suite

```bash
ruby scripts/run_visual_suite.rb
```

想定される出力:

```text
Wrote /path/to/kanbun-parser/out/variation-suite/report.md
Wrote /path/to/kanbun-parser/out/variation-suite/report.html
```

生成物:

```text
out/variation-suite/report.html
```

## 出力イメージ

下のプレビューは、`examples/academic-paper.md` を現行 CLI で組版した結果です。

![出力イメージ](docs/images/readme-final-result.png)

## 補足

- `out/` は生成物用ディレクトリであり、Git 管理対象ではありません。
- 主な CLI コマンドは `build` です。
- 調整項目は `jpmd.yml` と各 Markdown の `jpmd:` frontmatter で上書きできます。CLI フラグは今回のビルドに関する設定として、それらより優先されます。
- `jpmd build INPUT.md` は既定で `out/<入力ファイル名>.pdf` に出力します。`--output` で PDF パスを指定し、`--tex` で確認用 TeX を出力できます。
- 文献関連の CLI フラグは `--bibliography`、`--csl`、`--suppress-bibliography`、`--render-bibliography` です。
- 対応する文書 preset は `academic` です。
- 詳細は `docs/dependencies.md`、`docs/compile-and-adjust.md`、`docs/container-bootstrap.md` を参照してください。
