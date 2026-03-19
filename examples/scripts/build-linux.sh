#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
ruby bin/jpmd build examples/minimal-kanbun.md -o out/minimal-kanbun.pdf --emit-tex out/minimal-kanbun.tex
ruby bin/jpmd build examples/linear-kundoku.md -o out/linear-kundoku.pdf --emit-tex out/linear-kundoku.tex
