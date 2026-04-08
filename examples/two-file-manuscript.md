---
title: 参照ファイルを分けた原稿
subtitle: Markdown 本文と文献データを別ファイルで管理する例
author:
  - サンプル著者
institute:
  - Kanbun Parser Demo Lab
---

　本サンプルは、本文の Markdown と文献データの JSON を別々に管理しながら、最終的に一つの PDF として出力するための最小例である。文献データは CLI 側で差し込むため、本文ファイルには `bibliography` や `csl` を直接書かなくてもよい。脚注形式の典拠指定は通常どおり Pandoc の citation syntax を使える[@kawaguchi1966, pp. 471-472]。

　漢文注記も通常どおり記述できる。たとえば、[風]{f="かぜ"}は[宮鐘]{f="きゅうしょう"}を[送]{f="おく"}りて　[暁漏]{f="ぎょうろう"}[聞]{f="きこ"}ゆ、のように bracketed span を本文へ埋め込めばよい。
