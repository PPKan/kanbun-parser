# frozen_string_literal: true

require_relative "test_helper"

class JPMDCLITest < Minitest::Test
  def test_root_usage_mentions_yaml_first_build
    stdout, = capture_io do
      assert_equal 0, JPMD::CLI.start([])
    end

    assert_includes stdout, "jpmd build INPUT.md"
    refute_includes stdout, "build-pair"
  end

  def test_build_command_uses_default_project_config_path
    compiler = Object.new
    compiler.define_singleton_method(:build) { "/tmp/result.pdf" }
    captured = nil

    JPMD::Compiler.stub(:new, lambda { |**kwargs|
      captured = kwargs
      compiler
    }) do
      stdout, = capture_io do
        assert_equal 0, JPMD::CLI.start(["build", "draft.md"])
      end

      assert_includes stdout, "Wrote /tmp/result.pdf"
    end

    assert_equal File.expand_path("draft.md", Dir.pwd), captured.fetch(:input_path)
    assert_equal File.expand_path("jpmd.yml", Dir.pwd), captured.fetch(:config_path)
  end

  def test_build_pair_command_reports_migration_guidance
    _stdout, stderr = capture_io do
      assert_equal 1, JPMD::CLI.start(["build-pair", "draft.md", "library.json"])
    end

    assert_includes stderr, "build-pair"
    assert_includes stderr, "bibliography:"
    assert_includes stderr, "jpmd build INPUT.md"
  end
end
