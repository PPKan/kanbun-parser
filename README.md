# 漢語論文編譯工具 Kanbun Parser

這是一個利用 ruby、pandoc、LuaLatex 將 markdown 編譯成 pdf 的工具，特色如下：

1. 格式可自訂支援自訂邊界與行列字數
2. 支援日語讀音標記（振り仮名）、訓讀（送り仮名、返り点）
3. 支援文獻引用

最小範本與編譯流程如下，實作編譯前請先參考下方安裝流程。

### 準備檔案

basetsu.md

```markdown
## 韓愈「馬說」

[世]{o="ニ"}[有]{o="リ" k="二"}[伯樂]{k="一"}、[然]{o="ル"}[後]{o="ニ"}[有]{o="リ" k="二"}[千里馬]{k="一"}。

[世]{f="よ"}に[伯]{f="はく"}[楽]{f="らく"}あり、[然]{f="しか"}る[後]{f="のち"}に[千]{f="せん"}[里]{f="り"}[馬]{f="ば"}あり。

> 馬之千里者，一食或盡粟一石。食馬者不知其能千里而食也。是馬也，雖有千里之能，食不飽，力不足，才美不外見，且欲與常馬等不可得，安求其能千里也？[@basetsu, p.2-3]
```

library.json

```
[{"id":"basetsu","abstract":"韓愈 馬說","accessed":{"date-parts":[["2025",6,13]]},"author":[{"family":"韓","given":"愈"}],"citation-key":"basetsu","issued":{"date-parts":[["795"]]},"language":"ja","publisher":"出版社","source":"","title":"馬說","type":"book","URL":""}]
```

### 編譯流程

```
.\bin\jpmd.cmd build .\examples\readme-demo\basetsu.md --bibliography .\examples\readme-demo\library.json --output .\main.pdf --suppress-bibliography
```

### 結果

![result](https://raw.githubusercontent.com/PPKan/kanbun-parser/refs/heads/main/examples/readme-demo/result.png)



## 自訂項目

### 可用參數

支援自定義 input 與 output 位置與是否 render 文獻。

```
Usage:
  jpmd build INPUT.md [options]

Build options:
  -o, --output PDF             Write PDF to this path
      --tex TEX                Also write intermediate TeX to this path
  -b, --bibliography JSON      Use bibliography file; may be repeated
      --csl CSL                Use CSL style file
      --preset NAME            Use layout preset
      --suppress-bibliography  Do not render bibliography at the end
      --render-bibliography    Render bibliography at the end
  -h, --help                   Show command help
```

### 自定義格式

本編譯系統支援以文件內 yaml 為主的格式調整，支援調整邊界、每行字數、每頁字數、漢文標記尺寸與偏移，預設如下。

```
---
jpmd:
  preset: academic
  layout:
    margins:
      top: 3cm
      right: 3cm
      bottom: 2cm
      left: 3cm
    grid:
      characters_per_line: 35
      lines_per_page: 30
    font:
      body_size: 12pt
  kanbun:
    side:
      gap: 0.10zw
      min_width: 0.35zw
    furigana:
      size: 7pt
      shift:
        up: 0pt
        right: 0pt
        down: 0pt
        left: 0pt
    kaeriten:
      size: 7pt
      shift:
        up: 0pt
        right: 0pt
        down: 0.35ex
        left: 0pt
    okurigana:
      size: 7pt
      shift:
        up: 0pt
        right: 0pt
        down: 0pt
        left: 0pt
---

# 韓愈「馬說」

[世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="二"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば" k="一"}。[@basetsu, p.1]
```

### 



## Windows 安裝流程

1. 安裝 `Git` `Ruby` `Pandoc` `TeX Live` （`TeX Live` 需要很長的安裝時間）
2. 加入 tex 套件 `C:\texlive\2026\bin\windows\tlmgr.bat install jlreq luatexja titlesec haranoaji lualatex-math selnolig`
3. clone repo `git clone https://github.com/PPKan/kanbun-parser.git`



