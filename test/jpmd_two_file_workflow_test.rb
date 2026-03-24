# frozen_string_literal: true

require_relative "test_helper"

class JPMDTwoFileWorkflowTest < Minitest::Test
  def test_merged_markdown_keeps_document_metadata_and_injects_bibliography
    Dir.mktmpdir("jpmd-two-file-") do |dir|
      markdown_path = File.join(dir, "draft.md")
      bibliography_path = File.join(dir, "library.json")
      output_path = File.join(dir, "draft.pdf")
      config_path = File.join(dir, "jpmd.yml")

      File.write(markdown_path, <<~MARKDOWN, mode: "w:utf-8")
        ---
        title: Sample Title
        subtitle: Sample Subtitle
        author:
          - Sample Author
        institute:
          - Sample Institute
        jpmd:
          writing_mode: tate
        ---

        # Heading
      MARKDOWN
      File.write(bibliography_path, "[]\n", mode: "w:utf-8")
      File.write(config_path, "{}\n", mode: "w:utf-8")

      workflow = JPMD::TwoFileWorkflow.new(
        markdown_path: markdown_path,
        bibliography_path: bibliography_path,
        output_path: output_path,
        config_path: config_path,
        preset_name: nil,
        emit_tex_path: nil
      )

      merged = workflow.send(:merged_markdown)
      match = merged.match(/\A---\s*\n(.*?)\n---\s*\n\n/m)

      refute_nil match

      metadata = YAML.safe_load(match[1], aliases: true)
      body = merged[match[0].length..]

      assert_equal "Sample Title", metadata["title"]
      assert_equal "Sample Subtitle", metadata["subtitle"]
      assert_equal ["Sample Author"], metadata["author"]
      assert_equal ["Sample Institute"], metadata["institute"]
      assert_equal({ "writing_mode" => "tate" }, metadata["jpmd"])
      assert_equal File.expand_path(bibliography_path), metadata["bibliography"]
      assert_equal JPMD::TwoFileWorkflow::DEFAULT_CSL_PATH, metadata["csl"]
      assert_equal "# Heading\n", body
    end
  end

  def test_build_uses_temp_merged_input_and_default_preset
    Dir.mktmpdir("jpmd-two-file-") do |dir|
      markdown_path = File.join(dir, "draft.md")
      bibliography_path = File.join(dir, "library.json")
      output_path = File.join(dir, "draft.pdf")
      emit_tex_path = File.join(dir, "draft.tex")
      config_path = File.join(dir, "jpmd.yml")

      File.write(markdown_path, "# Heading\n", mode: "w:utf-8")
      File.write(bibliography_path, "[]\n", mode: "w:utf-8")
      File.write(config_path, "{}\n", mode: "w:utf-8")

      fake_compiler = Class.new do
        class << self
          attr_accessor :kwargs, :merged_input
        end

        def initialize(**kwargs)
          self.class.kwargs = kwargs
          @input_path = kwargs.fetch(:input_path)
          @output_path = kwargs.fetch(:output_path)
        end

        def build
          self.class.merged_input = File.read(@input_path, mode: "r:utf-8")
          @output_path
        end
      end

      workflow = JPMD::TwoFileWorkflow.new(
        markdown_path: markdown_path,
        bibliography_path: bibliography_path,
        output_path: output_path,
        config_path: config_path,
        preset_name: nil,
        emit_tex_path: emit_tex_path,
        compiler_class: fake_compiler
      )

      result = workflow.build

      assert_equal File.expand_path(output_path), result
      assert_equal "academic", fake_compiler.kwargs.fetch(:preset_name)
      assert_equal File.expand_path(output_path), fake_compiler.kwargs.fetch(:output_path)
      assert_equal File.expand_path(emit_tex_path), fake_compiler.kwargs.fetch(:emit_tex_path)
      refute_equal File.expand_path(markdown_path), fake_compiler.kwargs.fetch(:input_path)

      merged_metadata = YAML.safe_load(
        fake_compiler.merged_input.match(/\A---\s*\n(.*?)\n---\s*\n\n/m)[1],
        aliases: true
      )

      assert_equal File.expand_path(bibliography_path), merged_metadata.fetch("bibliography")
    end
  end

  def test_build_rejects_missing_bibliography_file
    Dir.mktmpdir("jpmd-two-file-") do |dir|
      markdown_path = File.join(dir, "draft.md")
      output_path = File.join(dir, "draft.pdf")
      config_path = File.join(dir, "jpmd.yml")

      File.write(markdown_path, "# Heading\n", mode: "w:utf-8")
      File.write(config_path, "{}\n", mode: "w:utf-8")

      workflow = JPMD::TwoFileWorkflow.new(
        markdown_path: markdown_path,
        bibliography_path: File.join(dir, "missing.json"),
        output_path: output_path,
        config_path: config_path,
        preset_name: nil,
        emit_tex_path: nil
      )

      error = assert_raises(JPMD::ValidationError) { workflow.build }
      assert_match(/Bibliography file not found/, error.message)
    end
  end
end
