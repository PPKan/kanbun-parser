# kanbun-parser

Languages: [English](README.md) | 日本語 | [繁體中文（台灣）](README.zh-Hant-TW.md)

`kanbun-parser` は、漢文訓点付きの日本語 Markdown を PDF に組むための最小構成リポジトリです。現在の `main` ブランチでは、Pandoc が Markdown を読み、`filter.lua` が漢文 span を TeX マクロへ変換し、LuaLaTeX が最終 PDF を生成します。

## このリポジトリに含まれるもの

- [document.md](document.md): 引用、脚注形式の文献、漢文記法を含む完全なサンプル。
- [document.pdf](document.pdf): 上記サンプルの参照用 PDF。
- [filter.lua](filter.lua): bracketed span を `\kanbun{...}{...}{...}{...}` に変換する Pandoc Lua フィルタ。
- [preamble.tex](preamble.tex): 和文レイアウトと漢文用マクロ定義。
- [template.tex](template.tex): ビルドに使う Pandoc 用 LaTeX テンプレート。
- [references/](references/): サンプル文献データと CSL。
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): 漢文だけを試す最小サンプル。
- [docs/images/readme-final-result.png](docs/images/readme-final-result.png): 下の README プレビュー画像。

## クイックスタート

必要なもの:

- `pandoc`
- `lualatex`
- `jlreq`、`luatexja-fontspec`、`luatexja-ruby`、`titlesec`、`fancyhdr`、`caption`、`longtable`、`booktabs`、`etoolbox` を含む TeX Live もしくは MiKTeX
- `Times New Roman`
- `MS Mincho`

コマンドはリポジトリのルートで実行してください。`main` のサンプルは LuaLaTeX から `Times New Roman` と `MS Mincho` を見つけられる前提です。

**Linux**

```bash
mkdir -p out
pandoc document.md \
  -f markdown+bracketed_spans \
  --standalone \
  --citeproc \
  --template template.tex \
  --lua-filter filter.lua \
  -t latex \
  -o out/document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/document.tex
```

**Windows PowerShell**

```powershell
New-Item -ItemType Directory -Path out -Force | Out-Null
pandoc .\document.md `
  -f markdown+bracketed_spans `
  --standalone `
  --citeproc `
  --template .\template.tex `
  --lua-filter .\filter.lua `
  -t latex `
  -o .\out\document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out .\out\document.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out .\out\document.tex
```

## 漢文だけ試したい場合

[examples/minimal-kanbun.md](examples/minimal-kanbun.md) は、引用や論文体裁なしで漢文記法だけを確認したい場合の最小例です。

```md
[世]{f="よ" o="ニ" k="二"}[有]{f="あ" o="リ" k="一"}[伯]{f="はく"}[樂]{f="らく"}。
```

ビルド手順は同じで、入力ファイルだけ差し替えます。

```bash
mkdir -p out
pandoc examples/minimal-kanbun.md \
  -f markdown+bracketed_spans \
  --standalone \
  --template template.tex \
  --lua-filter filter.lua \
  -t latex \
  -o out/minimal-kanbun.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/minimal-kanbun.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=out out/minimal-kanbun.tex
```

## 期待される出力

Pandoc は成功時にほとんど何も表示しません。最後の LuaLaTeX 実行では、次のような行が出れば正常です。

```text
Output written on out/document.pdf (6 pages, ... bytes).
```

最小サンプルでは次の形になります。

```text
Output written on out/minimal-kanbun.pdf (... pages, ... bytes).
```

生成される主なファイル:

- `out/document.tex`
- `out/document.pdf`
- `out/minimal-kanbun.tex`
- `out/minimal-kanbun.pdf`

## 最終結果デモ

下のプレビューは追跡済みの [document.pdf](document.pdf) から作成したもので、`main` ブランチが目標とする出力イメージです。

![最終結果デモ](docs/images/readme-final-result.png)

参照 PDF: [document.pdf](document.pdf)

## 重要なファイル

- [document.md](document.md): 文献と漢文記法を含む完全サンプル。
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): 漢文だけ試す最短の出発点。
- [filter.lua](filter.lua): bracketed span を TeX へ変換。
- [preamble.tex](preamble.tex): 版面、フォント、漢文配置の定義。
- [template.tex](template.tex): Pandoc の LaTeX テンプレート。

## 注意

- `\input{preamble.tex}` を解決するため、必ずリポジトリのルートで実行してください。
- Linux ではフォント不足が最も多い失敗要因です。`Times New Roman` と `MS Mincho` を先に用意してください。
- TeX Live の版が違うと、同じ入力でも改行位置が少し変わることがあります。
- `out/` は生成物置き場なので、いつでも削除できます。
