# frozen_string_literal: true

require_relative "test_helper"

class JPMDCompilerTest < Minitest::Test
  include JPMDTestHelper

  def test_resolve_font_setup_uses_exact_font_files_from_linux_directory
    with_temp_markdown do |input_path, config_path|
      Dir.mktmpdir("jpmd-fonts-") do |font_dir|
        %w[times.ttf timesbd.ttf timesi.ttf timesbi.ttf msmincho.ttc PMingLiU.ttf].each do |name|
          File.write(File.join(font_dir, name), "", mode: "wb")
        end

        compiler = compiler_for(input_path, config_path)
        previous = ENV["JPMD_WINDOWS_FONT_DIR"]
        ENV["JPMD_WINDOWS_FONT_DIR"] = font_dir

        compiler.stub(:pmingliu_altfont_entries, ['Range={"503C},Font={PMingLiU.ttf},Path={/tmp/fonts/},TateFont={PMingLiU.ttf},YokoFeatures={JFM=jlreq},TateFeatures={JFM=jlreqv}']) do
          font_setup = compiler.send(:resolve_font_setup)
          assert_includes font_setup.fetch(:latin), "times.ttf"
          assert_includes font_setup.fetch(:japanese), "msmincho.ttc"
          assert_includes font_setup.fetch(:japanese), "BoldFeatures={FakeBold=2}"
          assert_includes font_setup.fetch(:japanese), "AltFont={"
          assert_includes font_setup.fetch(:japanese), "PMingLiU.ttf"
          assert_includes font_setup.fetch(:japanese), "Range={\"503C}"
          assert_includes font_setup.fetch(:japanese), "YokoFeatures={JFM=jlreq}"
          assert_includes font_setup.fetch(:japanese), "TateFeatures={JFM=jlreqv}"
        end
      ensure
        ENV["JPMD_WINDOWS_FONT_DIR"] = previous
      end
    end
  end

  def test_missing_codepoints_for_fallback_detects_document_characters_not_in_ms_mincho
    with_temp_markdown("# 値 值 内 內\n") do |input_path, config_path|
      compiler = compiler_for(input_path, config_path)

      missing = compiler.send(
        :missing_codepoints_for_fallback,
        File.join(JPMD::Compiler::APP_ROOT, "vendor", "fonts", "msmincho.ttc"),
        File.join(JPMD::Compiler::APP_ROOT, "vendor", "fonts", "PMingLiU.ttf")
      )

      assert_equal [0x503C, 0x5167], missing
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
    with_temp_markdown({ "preset" => "linear" }) do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        config_path: config_path
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      template = compiler.send(:render_template)
      assert_includes template, "\\documentclass["
      assert_includes template, ",tate,"
    end
  end

  def test_render_metadata_exposes_tate_writing_mode_for_filter
    with_temp_markdown({ "preset" => "linear" }) do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        config_path: config_path
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      metadata = compiler.send(:render_metadata, "/tmp/preamble.tex")
      assert_includes metadata, "jpmd-writing-mode: tate"
    end
  end

  def test_pandoc_input_format_disables_yaml_metadata_blocks
    Dir.mktmpdir("jpmd-pandoc-format-") do |dir|
      input_path = File.join(dir, "input.md")
      config_path = File.join(dir, "jpmd.yml")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        <!-- comment -->

        ## Heading

        Paragraph

        ---

        More text
      MARKDOWN
      File.write(config_path, "default_preset: academic\n", mode: "w:utf-8")

      compiler = compiler_for(input_path, config_path)
      assert_equal "markdown+bracketed_spans-yaml_metadata_block", compiler.send(:pandoc_input_format)
    end
  end

  def test_pandoc_input_content_strips_yaml_frontmatter_before_pandoc
    Dir.mktmpdir("jpmd-pandoc-format-") do |dir|
      input_path = File.join(dir, "input.md")
      config_path = File.join(dir, "jpmd.yml")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        ---
        bibliography: refs.json
        ---

        # Heading
      MARKDOWN
      File.write(config_path, "default_preset: academic\n", mode: "w:utf-8")

      compiler = compiler_for(input_path, config_path)
      assert_equal "# Heading\n", compiler.send(:pandoc_input_content)
    end
  end

  def test_pandoc_input_content_removes_standalone_dash_rules_from_body
    Dir.mktmpdir("jpmd-pandoc-format-") do |dir|
      input_path = File.join(dir, "input.md")
      config_path = File.join(dir, "jpmd.yml")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        first

        ---
        ### heading

        second
      MARKDOWN
      File.write(config_path, "default_preset: academic\n", mode: "w:utf-8")

      compiler = compiler_for(input_path, config_path)
      assert_equal "first\n\n### heading\n\nsecond\n", compiler.send(:pandoc_input_content)
    end
  end

  def test_render_metadata_merges_document_frontmatter_except_jpmd
    Dir.mktmpdir("jpmd-pandoc-format-") do |dir|
      input_path = File.join(dir, "input.md")
      config_path = File.join(dir, "jpmd.yml")

      File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
        ---
        title: Sample Title
        subtitle: Sample Subtitle
        author:
          - Sample Author
        institute:
          - Department
          - sample@example.jp
        bibliography: refs.json
        csl: refs.csl
        suppress-bibliography: true
        header-includes:
          - \\foo
        jpmd:
          preset: academic
        ---

        # Heading
      MARKDOWN
      File.write(config_path, "default_preset: academic\n", mode: "w:utf-8")

      compiler = compiler_for(input_path, config_path)
      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      metadata = YAML.safe_load(compiler.send(:render_metadata, "/tmp/preamble.tex"))
      assert_equal "Sample Title", metadata["title"]
      assert_equal "Sample Subtitle", metadata["subtitle"]
      assert_equal ["Sample Author"], metadata["author"]
      assert_equal ["Department", "sample@example.jp"], metadata["institute"]
      assert_equal File.join(dir, "refs.json"), metadata["bibliography"]
      assert_equal File.join(dir, "refs.csl"), metadata["csl"]
      assert_equal true, metadata["suppress-bibliography"]
      assert_equal ["\\foo", "\\input{/tmp/preamble.tex}"], metadata["header-includes"]
      refute_includes metadata.keys, "jpmd"
    end
  end

  def test_build_copies_pdf_to_transfer_directory
    with_temp_markdown do |input_path, config_path|
      Dir.mktmpdir("jpmd-transfer-") do |dir|
        output_path = File.join(File.dirname(config_path), "out", "sample.pdf")
        transfer_dir = File.join(dir, "transfer")
        compiler = JPMD::Compiler.new(
          input_path: input_path,
          config_path: config_path
        )

        compiler.stub(:render_template, "template") do
          compiler.stub(:render_preamble, "preamble") do
            compiler.stub(:render_metadata, "---\n") do
              compiler.stub(:run_pandoc, lambda { |input_path:, template_path:, metadata_path:, tex_path:|
                assert File.file?(input_path)
                File.write(tex_path, "tex", mode: "w:utf-8")
              }) do
                compiler.stub(:run_lualatex, lambda { |tex_path, _workdir|
                  File.write(tex_path.sub(/\.tex\z/, ".pdf"), "pdf", mode: "wb")
                }) do
                  compiler.stub(:transfer_directory, transfer_dir) do
                    compiler.build
                  end
                end
              end
            end
          end
        end

        assert_equal "pdf", File.binread(output_path)
        assert_equal "pdf", File.binread(File.join(transfer_dir, "sample.pdf"))
      end
    end
  end

  def test_template_uses_paragraph_based_csl_references_environment
    template = File.read(File.join(JPMD::Compiler::APP_ROOT, "template.tex"), mode: "r:utf-8")

    assert_match(/\\newenvironment\{CSLReferences\}\[2\].*?\\setlength\{\\parindent\}\{0pt\}/m, template)
    assert_match(/\\newenvironment\{CSLReferences\}\[2\].*?\\def\\par\{\\hangindent=\\cslhangindent\\oldpar\}/m, template)
    refute_match(/\\newenvironment\{CSLReferences\}\[2\].*?\\begin\{list\}/m, template)
  end

  def test_template_renders_custom_yaml_title_block
    template = File.read(File.join(JPMD::Compiler::APP_ROOT, "template.tex"), mode: "r:utf-8")

    assert_includes template, "{\\fontsize{14pt}{14pt}\\selectfont\\bfseries $title$\\par}"
    assert_includes template, "{\\normalsize $subtitle$\\par}"
    refute_includes template, "\\vspace{0.5\\baselineskip}"
    assert_includes template, "\\begin{flushright}"
    assert_match(/\$for\(institute\)\$\$institute\$\\\\\n\$endfor\$\n\$for\(author\)\$\$author\$\\\\/m, template)
    refute_includes template, "\\maketitle"
  end

  def test_render_preamble_loads_kanbun_package_for_tate_mode
    with_temp_markdown({ "preset" => "linear" }) do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        config_path: config_path
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path
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

  def test_render_preamble_formats_nested_headings_for_academic_mode
    with_temp_markdown do |input_path, config_path|
      compiler = JPMD::Compiler.new(
        input_path: input_path,
        config_path: config_path
      )

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path
      ).resolve
      compiler.instance_variable_set(:@settings, resolved.fetch("settings"))
      compiler.instance_variable_set(:@derived, resolved.fetch("derived"))

      compiler.stub(:resolve_font_setup, { latin: "\\setmainfont{Times New Roman}", japanese: "\\setmainjfont{MS Mincho}" }) do
        preamble = compiler.send(:render_preamble)
        assert_includes preamble, "\\titleformat{\\subsection}"
        assert_includes preamble, "\\titleformat{\\subsubsection}"
        assert_includes preamble, "\\titleformat{\\paragraph}{\\normalfont\\bfseries}"
        refute_includes preamble, "\\titleformat{\\paragraph}[runin]"
      end
    end
  end

  private

  def compiler_for(input_path, config_path)
    JPMD::Compiler.new(
      input_path: input_path,
      config_path: config_path
    )
  end
end
