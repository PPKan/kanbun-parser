# kanbun-parser

Languages: [English](README.md) | [日本語](README.ja.md) | 繁體中文（台灣）

`kanbun-parser` 是一個精簡的參考型儲存庫，用來把帶有漢文訓點標記的日文 Markdown 編譯成 PDF。現在的 `main` 工作流程很直接：Pandoc 讀取 Markdown，`filter.lua` 把漢文 span 轉成 TeX 巨集，最後由 LuaLaTeX 產生 PDF。

## 這個儲存庫包含什麼

- [document.md](document.md): 完整範例，包含引文、文獻引用與漢文標記。
- [document.pdf](document.pdf): 上述範例的參考輸出 PDF。
- [filter.lua](filter.lua): 將 bracketed span 轉成 `\kanbun{...}{...}{...}{...}` 的 Pandoc Lua filter。
- [preamble.tex](preamble.tex): 日文版面設定與漢文巨集定義。
- [template.tex](template.tex): 建置用的 Pandoc LaTeX 樣板。
- [references/](references/): 範例書目資料與 CSL 樣式。
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): 只測試漢文編譯的最小範例。
- [docs/images/readme-final-result.png](docs/images/readme-final-result.png): 下方 README 預覽圖。

## 快速開始

需求:

- `pandoc`
- `lualatex`
- TeX Live 或 MiKTeX，並包含 `jlreq`、`luatexja-fontspec`、`luatexja-ruby`、`titlesec`、`fancyhdr`、`caption`、`longtable`、`booktabs`、`etoolbox`
- `Times New Roman`
- `MS Mincho`

請在儲存庫根目錄執行指令。`main` 上的範例假設 LuaLaTeX 能找到 `Times New Roman` 與 `MS Mincho`。

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

## 如果你只想編譯漢文

使用 [examples/minimal-kanbun.md](examples/minimal-kanbun.md)；這個檔案沒有引用與完整論文框架，只保留最小的漢文測試內容。

```md
[世]{f="よ" o="ニ" k="二"}[有]{f="あ" o="リ" k="一"}[伯]{f="はく"}[樂]{f="らく"}。
```

編譯方式相同，只要換掉輸入檔案：

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

## 預期輸出

Pandoc 成功時通常不會顯示太多訊息。最後一次 LuaLaTeX 應該會出現類似這樣的行：

```text
Output written on out/document.pdf (6 pages, ... bytes).
```

最小漢文範例則會是：

```text
Output written on out/minimal-kanbun.pdf (... pages, ... bytes).
```

完成後應該會看到：

- `out/document.tex`
- `out/document.pdf`
- `out/minimal-kanbun.tex`
- `out/minimal-kanbun.pdf`

## 最終結果示意

下面的預覽圖來自已追蹤的 [document.pdf](document.pdf)，代表這個儲存庫在 `main` 分支上希望達成的輸出風格。

![最終結果示意](docs/images/readme-final-result.png)

參考 PDF: [document.pdf](document.pdf)

## 重要檔案

- [document.md](document.md): 含文獻與漢文標記的完整範例。
- [examples/minimal-kanbun.md](examples/minimal-kanbun.md): 只想測試漢文時最快可用的起點。
- [filter.lua](filter.lua): 把 bracketed span 轉成 TeX。
- [preamble.tex](preamble.tex): 版面、字型與漢文配置設定。
- [template.tex](template.tex): Pandoc 的 LaTeX 樣板。

## 備註

- 請從儲存庫根目錄執行，讓 `\input{preamble.tex}` 能正確找到檔案。
- Linux 上最常見的失敗原因是缺字型；請先安裝或註冊 `Times New Roman` 與 `MS Mincho`。
- 即使輸入相同，不同版本的 TeX Live 仍可能造成些微換行差異。
- `out/` 是生成用工作目錄，隨時可以刪除。
