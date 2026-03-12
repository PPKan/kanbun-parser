---
numbersections: true
indent: true
geometry:
  - top=2.5cm
  - bottom=2.5cm
  - left=3cm
  - right=3cm
header-includes:
  - |
    \input{preamble.tex}
---

\begin{center}
{\fontsize{14pt}{14pt}\selectfont\bfseries Japanese Markdown Parser}
\end{center}

\begin{flushright}
山田 太郎\\
人文学研究科\\
准教授\\
taro.yamada@example.jp
\end{flushright}

本稿は、Pandoc と XeLaTeX を用いて和文学術文書の版面を再現しつつ、漢文訓読に必要なルビ、送り仮名、返り点を Markdown 上の注記として保持するための最小実装例である。原漢文の字順を改変せず、注記のみを重ねて組版することで、研究用原稿から PDF 出力までを単一のテキスト資源で管理できる。

# 漢文訓読の例

以下では、原文「世有伯樂、然後有千里馬。」を字順の変更なしに記述し、必要な訓点情報だけを bracketed span 属性として付与する。

[世]{f="よ" o="ニ" k="二"}[有]{f="あ" o="リ" k="一"}[伯]{f="はく"}[樂]{f="らく"}、[然]{f="しか" o="ル"}[後]{f="のち" o="ニ"}[有]{f="あ" o="リ" k="レ"}[千]{f="せん"}[里]{f="り"}[馬]{f="ば"}。
