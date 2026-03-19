# frozen_string_literal: true

require_relative "test_helper"

class JPMDCompilerTest < Minitest::Test
  include JPMDTestHelper

  def test_resolve_font_setup_uses_exact_font_files_from_linux_directory
    with_temp_markdown do |input_path, config_path|
      Dir.mktmpdir("jpmd-fonts-") do |font_dir|
        %w[times.ttf timesbd.ttf timesi.ttf timesbi.ttf msmincho.ttc].each do |name|
          File.write(File.join(font_dir, name), "", mode: "wb")
        end

        compiler = compiler_for(input_path, config_path)
        previous = ENV["JPMD_WINDOWS_FONT_DIR"]
        ENV["JPMD_WINDOWS_FONT_DIR"] = font_dir

        font_setup = compiler.send(:resolve_font_setup)
        assert_includes font_setup.fetch(:latin), "times.ttf"
        assert_includes font_setup.fetch(:japanese), "msmincho.ttc"
      ensure
        ENV["JPMD_WINDOWS_FONT_DIR"] = previous
      end
    end
  end

  def test_resolve_font_setup_explains_missing_fonts
    with_temp_markdown do |input_path, config_path|
      compiler = compiler_for(input_path, config_path)

      compiler.stub(:windows?, false) do
        compiler.stub(:resolve_times_new_roman_files, nil) do
          compiler.stub(:resolve_ms_mincho_file, nil) do
            compiler.stub(:font_family_available?, false) do
              error = assert_raises(JPMD::CommandError) { compiler.send(:resolve_font_setup) }
              assert_match(/Missing required fonts/, error.message)
              assert_match(/JPMD_WINDOWS_FONT_DIR/, error.message)
              assert_match(/JPMD_MS_MINCHO/, error.message)
            end
          end
        end
      end
    end
  end

  def test_render_template_adds_tate_class_option_for_linear_preset
    with_temp_markdown do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        output_path: File.join(File.dirname(input_path), "out.pdf"),
        config_path: config_path,
        preset_name: "linear",
        emit_tex_path: nil
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: "linear"
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      template = compiler.send(:render_template)
      assert_includes template, "\\documentclass["
      assert_includes template, ",tate,"
    end
  end

  def test_render_metadata_exposes_tate_writing_mode_for_filter
    with_temp_markdown do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        output_path: File.join(File.dirname(input_path), "out.pdf"),
        config_path: config_path,
        preset_name: "linear",
        emit_tex_path: nil
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: "linear"
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      metadata = compiler.send(:render_metadata, "/tmp/preamble.tex")
      assert_includes metadata, "jpmd-writing-mode: tate"
    end
  end

  def test_render_preamble_loads_kanbun_package_for_tate_mode
    with_temp_markdown do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        output_path: File.join(File.dirname(input_path), "out.pdf"),
        config_path: config_path,
        preset_name: "linear",
        emit_tex_path: nil
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: "linear"
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      compiler.stub(:resolve_font_setup, { latin: "\\setmainfont{Times New Roman}", japanese: "\\setmainjfont{MS Mincho}" }) do
        preamble = compiler.send(:render_preamble)
        assert_includes preamble, "\\usepackage["
        assert_includes preamble, "]{kanbun}"
        assert_includes preamble, "unit=1\\zw"
        assert_includes preamble, "\\newcommand{\\kanbun}[4]"
      end
    end
  end

  private

  def compiler_for(input_path, config_path)
    JPMD::Compiler.new(
      input_path: input_path,
      output_path: File.join(File.dirname(input_path), "out.pdf"),
      config_path: config_path,
      preset_name: nil,
      emit_tex_path: nil
    )
  end
end
