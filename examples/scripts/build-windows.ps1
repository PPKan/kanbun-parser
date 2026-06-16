$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot

ruby -Itest test/jpmd_config_test.rb
ruby -Itest test/jpmd_compiler_test.rb
.\bin\jpmd.cmd build .\examples\minimal-kanbun.md
.\bin\jpmd.cmd build .\examples\two-file-manuscript.md
