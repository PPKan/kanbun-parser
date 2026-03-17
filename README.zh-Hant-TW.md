# Kanbun Parser

語言: [English](README.md) | [日本語](README.ja.md) | 繁體中文（台灣）

Kanbun Parser 是一個 Ruby CLI，用 Pandoc 與 LuaLaTeX 把 Markdown 編譯成 PDF，並支援漢文訓讀常見的三種注記：

- 振假名
- 送假名
- 返點

這個 repo 主要服務兩種情境：

- 已經有完整 Markdown 文件，要排成日文學術風格 PDF
- 只想快速把一段漢文編譯出來

## Repo 主要內容

- `bin/jpmd` / `bin/jpmd.cmd`: CLI 入口
- `config/`: 集中放置可編輯的建置設定
- `config/jpmd.yml`: 預設版面設定與 preset 覆寫
- `config/pandoc/filter.lua`: 把漢文標記轉成 TeX 的 Pandoc filter
- `config/tex/`: jlreq 樣板與前置樣板
- `config/csl/chicago-notes-bibliography.csl`: 預設使用的通用 Zotero CSL
- `config/csl/custom/`: 保留舊的專案客製 CSL
- `examples/academic-paper.md`: 完整論文範例
- `examples/minimal-kanbun.md`: 只測漢文的最小範例
- `examples/references/`: 預設測試使用的通用 Zotero 書目範例
- `examples/references/custom/`: 保留舊的專案客製書目範例
- `examples/scripts/`: Linux / Windows 範例腳本
- `scripts/run_visual_suite.rb`: 產生 `out/variation-suite/report.html`
- `docs/images/readme-final-result.png`: 本 README 使用的範例輸出預覽圖
- `AGENTS.md`: 給 AI agent 的機器導向安裝文件

## 先用哪個範例

如果你已經有完整的 Markdown 文章，從 `examples/academic-paper.md` 開始。

如果你只是想編譯漢文，從 `examples/minimal-kanbun.md` 開始。這個檔案刻意只保留最基本的漢文語法。

```markdown
[世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="二"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば" k="一"}。
```

## 設定資料夾

現在使用者可直接調整的建置設定都集中在 `config/`。

- `config/jpmd.yml`: 預設版面設定與 preset 覆寫
- `config/tex/template.tex`: jlreq 文件骨架
- `config/tex/preamble.tex.erb`: 字型、行距與漢文巨集
- `config/pandoc/filter.lua`: bracketed span 到漢文 TeX 的轉換
- `config/csl/chicago-notes-bibliography.csl`: 論文範例預設使用的 CSL
- `config/csl/custom/`: 僅保留做參考的客製 CSL

執行 `jpmd build` 時，CLI 會依序尋找：

1. `./jpmd.yml`
2. `./config/jpmd.yml`
3. 內建的 `config/jpmd.yml`

如果你要直接調整這個 repo，就編輯 `config/` 內的檔案；如果只是想做獨立實驗，可以另外建立 YAML 並透過 `--config` 指定。

## 書目與 CSL 檔案

論文範例使用的書目輸入集中在 `examples/references/`。

- `examples/references/zotero-export.json`: 預設的 Zotero CSL JSON 範例
- `examples/references/zotero-export.bib`: 預設的 Zotero BibTeX 範例
- `config/csl/chicago-notes-bibliography.csl`: 預設的通用 CSL
- `examples/references/custom/` 與 `config/csl/custom/`: 舊的專案客製樣本

要換成自己的資料時，請編輯 Markdown frontmatter 內的 `bibliography:` 與 `csl:`。

```yaml
---
bibliography: path/to/your-library.bib
# 或：
# bibliography: path/to/your-library.json
csl: ../config/csl/chicago-notes-bibliography.csl
jpmd:
  preset: academic
---
```

`bibliography:` 與 `csl:` 會以宣告它們的 Markdown 檔案所在位置為基準。對 `examples/academic-paper.md` 來說，就是 `references/...` 與 `../config/...`。

## Linux 設定

以下以 Debian / Ubuntu 類系統為例。Linux 會自動使用 `vendor/fonts/` 內的字型檔。

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl fontconfig git pandoc perl poppler-utils python3-pil ruby tar xz-utils
```

安裝 TeX Live 2025，並加入這些套件：

```bash
/path/to/texlive/2025/bin/x86_64-linux/tlmgr install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

接著驗證並編譯：

```bash
git clone https://github.com/PPKan/kanbun-parser.git
cd kanbun-parser
export LUALATEX_PATH=/path/to/texlive/2025/bin/x86_64-linux/lualatex
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --emit-tex out/academic-paper.tex
```

預期輸出：

```text
Wrote /path/to/kanbun-parser/out/minimal-kanbun.pdf
Wrote /path/to/kanbun-parser/out/academic-paper.pdf
```

會得到的檔案：

- `out/minimal-kanbun.pdf`: 漢文最小範例的 PDF
- `out/minimal-kanbun.tex`: 方便檢查的 TeX 輸出
- `out/academic-paper.pdf`: 完整論文範例的 PDF
- `out/academic-paper.tex`: 方便檢查的 TeX 輸出

也可以直接跑範例腳本：

```bash
bash examples/scripts/build-linux.sh
```

## Windows 設定

請使用 PowerShell。先安裝並確認下列工具已在 `PATH`：

- Git
- Ruby
- Pandoc
- TeX Live 2025

Windows 端必須真的安裝這兩套字型：

- Times New Roman
- MS Mincho

加入 TeX 套件：

```powershell
C:\texlive\2025\bin\windows\tlmgr.bat install jlreq luatexja titlesec haranoaji lualatex-math selnolig
```

之後驗證並編譯：

```powershell
git clone https://github.com/PPKan/kanbun-parser.git
cd kanbun-parser
ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
.\bin\jpmd.cmd build .\examples\minimal-kanbun.md -o .\out\minimal-kanbun.pdf --emit-tex .\out\minimal-kanbun.tex
.\bin\jpmd.cmd build .\examples\academic-paper.md -o .\out\academic-paper.pdf --emit-tex .\out\academic-paper.tex
```

也可以跑 PowerShell 範例腳本：

```powershell
powershell -ExecutionPolicy Bypass -File .\examples\scripts\build-windows.ps1
```

## Visual Suite

```bash
ruby scripts/run_visual_suite.rb
```

預期輸出：

```text
Wrote /path/to/kanbun-parser/out/variation-suite/report.md
Wrote /path/to/kanbun-parser/out/variation-suite/report.html
```

產生的報告在：

```text
out/variation-suite/report.html
```

## 輸出預覽

下圖來自以目前 CLI 設定編譯 `examples/academic-paper.md` 後的輸出結果。

![輸出預覽](docs/images/readme-final-result.png)

## 補充

- `out/` 是產物目錄，預設不納入 Git。
- 全域設定會從 `./jpmd.yml`、`./config/jpmd.yml`，或內建的 `config/jpmd.yml` 讀取，單一文件仍可用 `jpmd:` frontmatter 覆寫。
- 更細的說明請看 `docs/dependencies.md`、`docs/compile-and-adjust.md`、`docs/container-bootstrap.md`。
