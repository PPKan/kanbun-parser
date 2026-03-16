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

- choose `Paste Markdown` or `Upload Markdown File`
- adjust the visible layout controls
- open the advanced section for kanbun-side geometry
- click `Build PDF`
- the app returns the generated PDF directly

## Notes

- uploads accept `.md` and `.markdown`
- uploads accept `text/markdown` and `text/plain`
- each request builds in a temp workspace
- bundled `references/` are copied into that workspace so the citation sample still resolves
- there is no persistence, history, account system, or async queue in v1
- the app still uses the exact existing fonts: `Times New Roman` and `MS Mincho`
- on Linux, if those fonts are not installed system-wide, point the compiler at the exact font files before starting the server:

```bash
export JPMD_WINDOWS_FONT_DIR=/path/to/fonts
bundle exec ruby bin/jpmd serve --host 127.0.0.1 --port 4567
```
