# frozen_string_literal: true

require_relative "test_helper"
require_relative "../lib/jpmd/web_builder"

class JPMDWebBuilderTest < Minitest::Test
  class FakeCompiler
    class << self
      attr_accessor :last_options
    end

    def initialize(**options)
      self.class.last_options = options
    end

    def build
      workspace = self.class.last_options.fetch(:working_dir)
      input_path = self.class.last_options.fetch(:input_path)
      output_path = self.class.last_options.fetch(:output_path)
      request_config_path = File.join(workspace, "request.jpmd.yml")

      raise "document.md was not written" unless File.read(input_path, mode: "r:utf-8").include?("本文")
      raise "request config missing" unless File.file?(request_config_path)
      raise "references not copied" unless File.file?(File.join(workspace, "references", "sample-zotero.json"))

      File.write(output_path, "%PDF-builder-test", mode: "wb")
      output_path
    end
  end

  def test_build_writes_workspace_and_passes_runtime_overrides
    builder = JPMD::WebBuilder.new(repo_root: File.expand_path("..", __dir__), compiler_class: FakeCompiler)
    result = builder.build(
      source_text: "# Title\n\n本文",
      source_name: "sample.md",
      overrides: {
        "layout" => {
          "grid" => {
            "characters_per_line" => "28"
          }
        }
      }
    )

    assert_equal "%PDF-builder-test", result.fetch("pdf_data")
    assert_equal "sample.pdf", result.fetch("download_name")
    assert_equal File.expand_path("../jpmd.yml", __dir__), FakeCompiler.last_options.fetch(:config_path)
    assert_equal File.expand_path("..", __dir__), FakeCompiler.last_options.fetch(:asset_root)
    assert_equal "28", FakeCompiler.last_options.dig(:runtime_overrides, "layout", "grid", "characters_per_line")
  end
end
