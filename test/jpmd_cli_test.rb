# frozen_string_literal: true

require_relative "test_helper"

class JPMDCLITest < Minitest::Test
  def test_root_usage_mentions_yaml_first_build
    stdout, = capture_io do
      assert_equal 0, JPMD::CLI.start([])
    end

    assert_includes stdout, "jpmd build INPUT.md"
    assert_includes stdout, "--bibliography JSON"
    assert_includes stdout, "--output PDF"
    assert_includes stdout, "--render-bibliography"
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

  def test_build_command_passes_cli_overrides_to_compiler
    compiler = Object.new
    compiler.define_singleton_method(:build) { "/tmp/out.pdf" }
    captured = nil

    JPMD::Compiler.stub(:new, lambda { |**kwargs|
      captured = kwargs
      compiler
    }) do
      stdout, = capture_io do
        assert_equal 0, JPMD::CLI.start([
          "build",
          "draft.md",
          "--output", "transfer/draft.pdf",
          "--tex", "transfer/draft.tex",
          "--bibliography", "refs.json",
          "--bibliography", "extra.json",
          "--csl", "style.csl",
          "--preset", "linear",
          "--suppress-bibliography"
        ])
      end

      assert_includes stdout, "Wrote /tmp/out.pdf"
    end

    assert_equal File.expand_path("transfer/draft.pdf", Dir.pwd), captured.fetch(:output_path)
    assert_equal File.expand_path("transfer/draft.tex", Dir.pwd), captured.fetch(:emit_tex_path)
    assert_equal "linear", captured.fetch(:preset_name)
    assert_equal(
      {
        "bibliography" => [
          File.expand_path("refs.json", Dir.pwd),
          File.expand_path("extra.json", Dir.pwd)
        ],
        "csl" => File.expand_path("style.csl", Dir.pwd),
        "suppress-bibliography" => true
      },
      captured.fetch(:metadata_overrides)
    )
  end

  def test_build_command_can_force_bibliography_rendering
    compiler = Object.new
    compiler.define_singleton_method(:build) { "/tmp/out.pdf" }
    captured = nil

    JPMD::Compiler.stub(:new, lambda { |**kwargs|
      captured = kwargs
      compiler
    }) do
      capture_io do
        assert_equal 0, JPMD::CLI.start(["build", "draft.md", "--render-bibliography"])
      end
    end

    assert_equal({ "suppress-bibliography" => false }, captured.fetch(:metadata_overrides))
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
