# frozen_string_literal: true

require "open3"
require_relative "test_helper"

class FilterTateModeTest < Minitest::Test
  def test_tate_mode_converts_annotated_paragraph_to_kanbun_block
    Dir.mktmpdir("jpmd-filter-") do |dir|
      input_path = File.join(dir, "sample.md")
      metadata_path = File.join(dir, "metadata.yml")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        [世]{f="よ" o="ニ"}[有]{f="あ" o="リ" k="二"}[伯]{f="はく"}[樂]{f="らく" k="一"}。
      MARKDOWN
      File.write(metadata_path, YAML.dump({ "jpmd-writing-mode" => "tate" }), mode: "w:utf-8")

      stdout, status = Open3.capture2(
        "pandoc",
        input_path,
        "-f", "markdown+bracketed_spans",
        "--metadata-file", metadata_path,
        "--lua-filter", File.expand_path("../filter.lua", __dir__),
        "-t", "latex"
      )

      assert status.success?, stdout
      assert_includes stdout, "\\Kanbun"
      assert_includes stdout, "世(よ){ニ}"
      assert_includes stdout, "有(あ){リ}[二]"
      assert_includes stdout, "\\printkanbunnopar\\par"
      refute_includes stdout, "\\kanbun{"
    end
  end

  def test_horizontal_rules_are_dropped
    Dir.mktmpdir("jpmd-filter-") do |dir|
      input_path = File.join(dir, "sample.md")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        first

        ---

        second
      MARKDOWN

      stdout, status = Open3.capture2(
        "pandoc",
        input_path,
        "-f", "markdown+hard_line_breaks",
        "--lua-filter", File.expand_path("../filter.lua", __dir__),
        "-t", "latex"
      )

      assert status.success?, stdout
      assert_includes stdout, "first"
      assert_includes stdout, "second"
      refute_includes stdout, "\\begin{center}\\rule{0.5\\linewidth}{0.5pt}\\end{center}"
    end
  end

  def test_soft_breaks_become_latex_line_breaks_without_breaking_headers
    Dir.mktmpdir("jpmd-filter-") do |dir|
      input_path = File.join(dir, "sample.md")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        first
        second

        #### Heading

        third
        fourth
      MARKDOWN

      stdout, status = Open3.capture2(
        "pandoc",
        input_path,
        "-f", "markdown+bracketed_spans",
        "--lua-filter", File.expand_path("../filter.lua", __dir__),
        "-t", "latex"
      )

      assert status.success?, stdout
      assert_includes stdout, "first\\\\\nsecond"
      assert_includes stdout, "\\paragraph{Heading}"
      assert_includes stdout, "third\\\\\nfourth"
    end
  end

  def test_tables_render_with_inner_rules_only
    Dir.mktmpdir("jpmd-filter-") do |dir|
      input_path = File.join(dir, "sample.md")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        | [風]{f="かぜ"} | B | C |
        |---|---|---|
        | 1 | 2 | 3 |
        | 4 | 5 | 6 |
      MARKDOWN

      stdout, status = Open3.capture2(
        "pandoc",
        input_path,
        "-f", "markdown+bracketed_spans",
        "--lua-filter", File.expand_path("../filter.lua", __dir__),
        "-t", "latex"
      )

      assert status.success?, stdout
      assert_includes stdout, "\\begin{longtable}[]{@{}l|l|l@{}}"
      assert_includes stdout, "\\kanbun{風}{かぜ}{}{} & B & C \\\\"
      assert_includes stdout, "\\cline{1-3}"
      refute_includes stdout, "\\toprule"
      refute_includes stdout, "\\midrule"
      refute_includes stdout, "\\bottomrule"
      refute_match(/\\cline\{1-3\}\n\\end\{longtable\}/, stdout)
    end
  end
end
