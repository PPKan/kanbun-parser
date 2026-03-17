# Kanbun Parser

言語: [English](README.md) | 日本語 | [繁體中文（台灣）](README.zh-Hant-TW.md)

Kanbun Parser は、Markdown を Pandoc と LuaLaTeX 経由で PDF に変換する Ruby 製 CLI です。漢文の注記として次を扱えます。

- 振り仮名
- 送り仮名
- 返り点

主な用途は二つです。

- Markdown で書いた和文学術文書を PDF に組版する
- 漢文だけをすぐに試し組みする

## 主な構成

- `bin/jpmd` / `bin/jpmd.cmd`: CLI エントリポイント
- `config/`: 利用者が編集する設定一式
- `config/jpmd.yml`: 既定設定と preset 上書き
- `config/pandoc/filter.lua`: 漢文注記を TeX に変換する Pandoc フィルタ
- `config/tex/`: jlreq テンプレートと前置きテンプレート
- `config/csl/chicago-notes-bibliography.csl`: 既定で使う一般的な Zotero 向け CSL
- `config/csl/custom/`: 旧来のプロジェクト専用 CSL を保管
- `examples/academic-paper.md`: 論文形式のサンプル
- `examples/minimal-kanbun.md`: 漢文だけを試す最小サンプル
- `examples/references/`: 既定テストで使う一般的な Zotero 文献サンプル
- `examples/references/custom/`: 旧来のプロジェクト専用文献サンプル
- `examples/scripts/`: Linux / Windows 用サンプルスクリプト
- `scripts/run_visual_suite.rb`: `out/variation-suite/report.html` を生成
- `docs/images/readme-final-result.png`: この README で使う組版結果のプレビュー画像
- `AGENTS.md`: AI エージェント向けセットアップ文書

## どのサンプルから始めるか

完成した Markdown 文書を持っている場合は `examples/academic-paper.md` を基準にしてください。

漢文だけを組みたい場合は `examples/minimal-kanbun.md` を使ってください。最小例は漢文記法だけに絞っています。

```markdown
[世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="二"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば" k="一"}。
```

## 設定フォルダ

利用者が直接調整する設定は `config/` にまとめました。

- `config/jpmd.yml`: 既定のレイアウト設定と preset 上書き
- `config/tex/template.tex`: jlreq ベースの文書テンプレート
- `config/tex/preamble.tex.erb`: フォント、行送り、漢文マクロ
- `config/pandoc/filter.lua`: bracketed span を漢文 TeX に変換
- `config/csl/chicago-notes-bibliography.csl`: 論文サンプルで既定利用する CSL
- `config/csl/custom/`: 参照用に残したカスタム CSL

`jpmd build` は次の順で設定ファイルを探します。

1. `./jpmd.yml`
2. `./config/jpmd.yml`
3. 同梱の `config/jpmd.yml`

このリポジトリ自体を調整するなら `config/` を直接編集してください。別案を試すだけなら、新しい YAML を作って `--config` を渡せます。

## 文献ファイルと CSL

論文サンプルの文献入力は `examples/references/` にまとめています。

- `examples/references/zotero-export.json`: 既定の Zotero CSL JSON サンプル
- `examples/references/zotero-export.bib`: 既定の Zotero BibTeX サンプル
- `config/csl/chicago-notes-bibliography.csl`: 既定の一般向け CSL
- `examples/references/custom/` と `config/csl/custom/`: 旧来のプロジェクト専用サンプル

自分の文献に差し替えるときは、Markdown frontmatter の `bibliography:` と `csl:` を編集します。

```yaml
---
bibliography: path/to/your-library.bib
# あるいは
# bibliography: path/to/your-library.json
csl: ../config/csl/chicago-notes-bibliography.csl
jpmd:
  preset: academic
---
```

`bibliography:` と `csl:` のパスは、それを書いた Markdown ファイル基準で読まれます。`examples/academic-paper.md` では `references/...` と `../config/...` です。

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

想定される出力:

```text
Wrote /path/to/kanbun-parser/out/minimal-kanbun.pdf
Wrote /path/to/kanbun-parser/out/academic-paper.pdf
```

生成されるファイル:

- `out/minimal-kanbun.pdf`: 漢文だけのサンプル PDF
- `out/minimal-kanbun.tex`: 確認用に出力された TeX
- `out/academic-paper.pdf`: 論文形式サンプル PDF
- `out/academic-paper.tex`: 確認用に出力された TeX

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
- 調整項目は `./jpmd.yml`、`./config/jpmd.yml`、または同梱の `config/jpmd.yml` から読み込まれ、各 Markdown の `jpmd:` frontmatter で上書きできます。
- 詳細は `docs/dependencies.md`、`docs/compile-and-adjust.md`、`docs/container-bootstrap.md` を参照してください。
