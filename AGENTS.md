# AGENTS.md

Use this file as the primary bootstrap contract for automation.

```yaml
repo:
  name: kanbun-parser
  root_required: true
  primary_goal: compile markdown to PDF with kanbun annotations

entrypoints:
  cli_unix: ruby bin/jpmd
  cli_windows: .\\bin\\jpmd.cmd
  visual_suite: ruby scripts/run_visual_suite.rb

examples:
  full_document: examples/academic-paper.md
  kanbun_only: examples/minimal-kanbun.md
  bibliography_samples: examples/references
  linux_script: examples/scripts/build-linux.sh
  windows_script: examples/scripts/build-windows.ps1

required_tools:
  common:
    - ruby
    - pandoc
    - lualatex
  texlive_packages:
    - jlreq
    - luatexja
    - titlesec
    - haranoaji
    - lualatex-math
    - selnolig

font_rules:
  linux:
    preferred_source: vendor/fonts
    required_files:
      - vendor/fonts/times.ttf
      - vendor/fonts/timesbd.ttf
      - vendor/fonts/timesi.ttf
      - vendor/fonts/timesbi.ttf
      - vendor/fonts/msmincho.ttc
  windows:
    required_installed_fonts:
      - Times New Roman
      - MS Mincho

environment_variables:
  optional:
    - PANDOC_PATH
    - LUALATEX_PATH
    - JPMD_WINDOWS_FONT_DIR
    - JPMD_TIMES_NEW_ROMAN_REGULAR
    - JPMD_TIMES_NEW_ROMAN_BOLD
    - JPMD_TIMES_NEW_ROMAN_ITALIC
    - JPMD_TIMES_NEW_ROMAN_BOLD_ITALIC
    - JPMD_MS_MINCHO

verification:
  tests:
    - ruby -Itest test/jpmd_config_test.rb
    - ruby -Itest test/jpmd_compiler_test.rb
  sample_builds_unix:
    - ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
    - ruby bin/jpmd build examples/academic-paper.md -o out/academic-paper.pdf --emit-tex out/academic-paper.tex
  sample_builds_windows:
    - .\\bin\\jpmd.cmd build .\\examples\\minimal-kanbun.md -o .\\out\\minimal-kanbun.pdf --emit-tex .\\out\\minimal-kanbun.tex
    - .\\bin\\jpmd.cmd build .\\examples\\academic-paper.md -o .\\out\\academic-paper.pdf --emit-tex .\\out\\academic-paper.tex
  visual_suite:
    - ruby scripts/run_visual_suite.rb
    - report_path: out/variation-suite/report.html

operating_notes:
  - run commands from repo root
  - out/ is generated and gitignored
  - bundled project defaults are in config/jpmd.yml
  - cli config lookup is ./jpmd.yml, then ./config/jpmd.yml, then bundled config/jpmd.yml
  - document overrides are read from jpmd: YAML frontmatter
  - default academic-paper bibliography samples live in examples/references and its default CSL file lives in config/csl
  - older project-specific bibliography and CSL assets are kept under the matching custom/ folders with notes
  - kanbun syntax is [BASE]{f=\"...\" o=\"...\" k=\"...\"}
  - visual suite cases are defined in test/variation_suite.yml

failure_triage:
  missing_pandoc: set PANDOC_PATH or install pandoc on PATH
  missing_lualatex: set LUALATEX_PATH or install TeX Live 2025
  missing_fonts_linux: verify vendor/fonts or font env vars
  missing_fonts_windows: install Times New Roman and MS Mincho
  latex_failure: inspect emitted tex with --emit-tex and rerun
```
