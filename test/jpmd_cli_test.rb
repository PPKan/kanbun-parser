# frozen_string_literal: true

require_relative "test_helper"

class JPMDCLITest < Minitest::Test
  def test_root_usage_mentions_build_pair
    stdout, = capture_io do
      assert_equal 0, JPMD::CLI.start([])
    end

    assert_includes stdout, "jpmd build-pair INPUT.md REFERENCES.json"
  end

  def test_build_pair_command_uses_two_file_workflow_defaults
    workflow = Object.new
    workflow.define_singleton_method(:build) { "/tmp/result.pdf" }
    captured = nil

    JPMD::TwoFileWorkflow.stub(:new, lambda { |**kwargs|
      captured = kwargs
      workflow
    }) do
      stdout, = capture_io do
        assert_equal 0, JPMD::CLI.start(["build-pair", "draft.md", "library.json", "-o", "out/result.pdf"])
      end

      assert_includes stdout, "Wrote /tmp/result.pdf"
    end

    assert_equal File.expand_path("draft.md", Dir.pwd), captured.fetch(:markdown_path)
    assert_equal File.expand_path("library.json", Dir.pwd), captured.fetch(:bibliography_path)
    assert_equal File.expand_path("out/result.pdf", Dir.pwd), captured.fetch(:output_path)
    assert_equal File.expand_path("jpmd.yml", Dir.pwd), captured.fetch(:config_path)
    assert_equal "academic", captured.fetch(:preset_name)
    assert_equal JPMD::TwoFileWorkflow::DEFAULT_CSL_PATH, captured.fetch(:csl_path)
  end
end
