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
      metadata_overrides = self.class.last_options.fetch(:pandoc_metadata_overrides)

      raise "document.md was not written" unless File.read(input_path, mode: "r:utf-8").include?("本文")
      raise "request config missing" unless File.file?(request_config_path)
      raise "references not copied" unless File.file?(File.join(workspace, "references", "zotero-export.json"))
      raise "sample bibliography missing" unless File.file?(File.join(workspace, metadata_overrides.fetch("bibliography")))
      raise "sample csl missing" unless File.file?(File.join(workspace, metadata_overrides.fetch("csl")))
      if metadata_overrides.fetch("bibliography").start_with?("uploads/")
        raise "uploaded bibliography missing" unless File.file?(File.join(workspace, metadata_overrides.fetch("bibliography")))
      end
      if metadata_overrides.fetch("csl").start_with?("uploads/")
        raise "uploaded csl missing" unless File.file?(File.join(workspace, metadata_overrides.fetch("csl")))
      end

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
      },
      bibliography: {
        "mode" => "sample",
        "kind" => "bibliography",
        "workspace_path" => "references/zotero-export.json"
      },
      csl: {
        "mode" => "sample",
        "kind" => "csl",
        "workspace_path" => "references/chicago-notes-bibliography.csl"
      }
    )

    assert_equal "%PDF-builder-test", result.fetch("pdf_data")
    assert_equal "sample.pdf", result.fetch("download_name")
    assert_equal File.expand_path("../jpmd.yml", __dir__), FakeCompiler.last_options.fetch(:config_path)
    assert_equal File.expand_path("..", __dir__), FakeCompiler.last_options.fetch(:asset_root)
    assert_equal "28", FakeCompiler.last_options.dig(:runtime_overrides, "layout", "grid", "characters_per_line")
    assert_equal "references/zotero-export.json", FakeCompiler.last_options.dig(:pandoc_metadata_overrides, "bibliography")
    assert_equal "references/chicago-notes-bibliography.csl", FakeCompiler.last_options.dig(:pandoc_metadata_overrides, "csl")
  end

  def test_build_writes_uploaded_bibliography_and_csl
    builder = JPMD::WebBuilder.new(repo_root: File.expand_path("..", __dir__), compiler_class: FakeCompiler)
    builder.build(
      source_text: "# Title\n\n本文",
      source_name: "sample.md",
      overrides: {},
      bibliography: {
        "mode" => "upload",
        "kind" => "bibliography",
        "filename" => "custom library.json",
        "content" => "[{\"id\":\"demo\"}]"
      },
      csl: {
        "mode" => "upload",
        "kind" => "csl",
        "filename" => "custom style.csl",
        "content" => "<style></style>"
      }
    )

    workspace = FakeCompiler.last_options.fetch(:working_dir)
    assert_equal "uploads/custom-library.json", FakeCompiler.last_options.dig(:pandoc_metadata_overrides, "bibliography")
    assert_equal "uploads/custom-style.csl", FakeCompiler.last_options.dig(:pandoc_metadata_overrides, "csl")
  end
end
