$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot

ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
.\bin\jpmd.cmd build .\examples\minimal-kanbun.md -o .\out\minimal-kanbun.pdf --emit-tex .\out\minimal-kanbun.tex
.\bin\jpmd.cmd build .\examples\linear-kundoku.md -o .\out\linear-kundoku.pdf --emit-tex .\out\linear-kundoku.tex
.\bin\jpmd.cmd build-pair .\examples\two-file-manuscript.md .\references\sample-zotero.json -o .\out\two-file-manuscript.pdf --emit-tex .\out\two-file-manuscript.tex
