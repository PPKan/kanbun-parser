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
end
