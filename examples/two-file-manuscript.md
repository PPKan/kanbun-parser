---
title: 参考文献を埋め込んだ原稿
subtitle: Markdown frontmatter だけで文献情報も渡す例
author:
  - サンプル著者
institute:
  - Kanbun Parser Demo Lab
bibliography: ../references/sample-zotero.json
csl: ../references/word-japanese-note.csl
jpmd:
  preset: academic
  output:
    tex: ../out/two-file-manuscript.tex
---

　本サンプルは、本文の Markdown frontmatter に文献データと CSL スタイルを直接書き込み、単一ファイルのまま最終 PDF を出力するための最小例である。脚注形式の典拠指定は通常どおり Pandoc の citation syntax を使える[@kawaguchi1966, pp. 471-472]。

　漢文注記も通常どおり記述できる。たとえば、[風]{f="かぜ"}は[宮鐘]{f="きゅうしょう"}を[送]{f="おく"}りて　[暁漏]{f="ぎょうろう"}[聞]{f="きこ"}ゆ、のように bracketed span を本文へ埋め込めばよい。
