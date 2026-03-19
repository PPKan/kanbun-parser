# Kanbun Parser

語言: [English](README.md) | [日本語](README.ja.md) | 繁體中文（台灣）

Kanbun Parser 是一個 Ruby CLI，用 Pandoc 與 LuaLaTeX 把 Markdown 編譯成 PDF，並支援漢文訓讀常見的三種注記：

- 振假名
- 送假名
- 返點

這個 repo 主要服務三種情境：

- 已經有完整 Markdown 文件，要排成日文學術風格 PDF
- 只想快速把一段漢文編譯出來
- 用線裝風的縱排欄位試作漢文訓讀版面

## Repo 主要內容

- `bin/jpmd` / `bin/jpmd.cmd`: CLI 入口
- `jpmd.yml`: 專案預設版面設定
- `examples/academic-paper.md`: 完整論文範例
- `examples/linear-kundoku.md`: 以《馬説》為底的縱排訓讀試作
- `examples/minimal-kanbun.md`: 只測漢文的最小範例
- `examples/scripts/`: Linux / Windows 範例腳本
- `filter.lua`: Pandoc 過濾器，將漢文標記轉成 TeX
- `templates/preamble.tex.erb`: 組版與漢文註記模板
- `scripts/run_visual_suite.rb`: 產生 `out/variation-suite/report.html`
- `docs/images/readme-final-result.png`: 本 README 使用的範例輸出預覽圖
- `AGENTS.md`: 給 AI agent 的機器導向安裝文件

## 先用哪個範例

如果你要先做縱排訓讀試作，從 `examples/linear-kundoku.md` 開始。

如果你已經有完整的橫排 Markdown 文章，`examples/academic-paper.md` 仍然是 yoko 參考範例。

如果你只是想編譯漢文，從 `examples/minimal-kanbun.md` 開始。這個檔案刻意只保留最基本的漢文語法。

```markdown
[世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="二"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば" k="一"}。
```

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
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku.pdf --emit-tex out/linear-kundoku.tex
```

預期輸出：

```text
Wrote /path/to/kanbun-parser/out/minimal-kanbun.pdf
Wrote /path/to/kanbun-parser/out/linear-kundoku.pdf
```

會得到的檔案：

- `out/minimal-kanbun.pdf`: 漢文最小範例的 PDF
- `out/minimal-kanbun.tex`: 方便檢查的 TeX 輸出
- `out/linear-kundoku.pdf`: 縱排訓讀試作 PDF
- `out/linear-kundoku.tex`: 方便檢查的 TeX 輸出

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
.\bin\jpmd.cmd build .\examples\linear-kundoku.md -o .\out\linear-kundoku.pdf --emit-tex .\out\linear-kundoku.tex
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
- 全域設定在 `jpmd.yml`，單一文件可用 `jpmd:` frontmatter 覆寫。
- 這個分支新增了 `linear` 內建 preset，作為縱排訓讀的預設輸出；`academic` 則保留作橫排參考。
- 更細的說明請看 `docs/dependencies.md`、`docs/compile-and-adjust.md`、`docs/container-bootstrap.md`。
