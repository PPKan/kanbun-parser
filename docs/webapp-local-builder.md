# Local Web PDF Builder

This branch adds a local-only Sinatra app around the existing Ruby compiler.

## Install

```bash
bundle install
```

## Run

```bash
bundle exec ruby bin/jpmd serve --host 127.0.0.1 --port 4567
```

Then open:

```text
http://127.0.0.1:4567
```

## Behavior

- start from a bundled sample, paste Markdown, or upload a Markdown file
- choose bundled citation assets, upload your own Zotero/BibTeX or CSL files, or keep the Markdown frontmatter paths
- adjust the visible layout controls
- open the advanced section for kanbun-side geometry
- click `Build PDF`
- the app returns the generated PDF directly

## Bundled Samples

Source documents available directly in the app:

- `examples/academic-paper.md`
- `examples/minimal-kanbun.md`
- `test/fixtures/kanbun-visual.md`

Bundled citation assets available directly in the app:

- `references/zotero-export.json`
- `references/zotero-export.bib`
- `references/chicago-notes-bibliography.csl`

Reference-only custom citation assets are also bundled:

- `references/custom/japanese-note-sample.json`
- `references/custom/japanese-note-sample.bib`
- `references/custom/word-japanese-note.csl`

## Notes

- uploads accept `.md` and `.markdown`
- bibliography uploads accept `.json` and `.bib`
- CSL uploads accept `.csl`
- Markdown uploads accept `text/markdown` and `text/plain`
- each request builds in a temp workspace
- bundled `references/` are copied into that workspace so the sample documents and citation assets still resolve
- uploaded bibliography and CSL files are written into that temp workspace only for the current request
- there is no persistence, history, account system, or async queue in v1
- the app still uses the exact existing fonts: `Times New Roman` and `MS Mincho`
- on Linux, if those fonts are not installed system-wide, point the compiler at the exact font files before starting the server:

```bash
export JPMD_WINDOWS_FONT_DIR=/path/to/fonts
bundle exec ruby bin/jpmd serve --host 127.0.0.1 --port 4567
```
