# frozen_string_literal: true

require "erb"
require "fileutils"
require "open3"
require "pathname"
require "rbconfig"
require "tempfile"
require "tmpdir"
require "yaml"

module JPMD
  class Compiler
    WINDOWS_PANDOC = File.expand_path("~/AppData/Local/Pandoc/pandoc.exe")
    WINDOWS_LUALATEX = "C:/texlive/2025/bin/windows/lualatex.exe"
    APP_ROOT = File.expand_path("../..", __dir__)

    def initialize(input_path:, output_path:, config_path:, preset_name:, emit_tex_path:)
      @input_path = File.expand_path(input_path)
      @output_path = File.expand_path(output_path)
      @config_path = File.expand_path(config_path)
      @preset_name = preset_name
      @emit_tex_path = emit_tex_path && File.expand_path(emit_tex_path)
    end

    def build
      ensure_input_exists

      resolved = JPMD::Config.new(
        input_path: @input_path,
        config_path: @config_path,
        cli_preset: @preset_name
      ).resolve

      @settings = resolved.fetch("settings")
      @derived = resolved.fetch("derived")

      FileUtils.mkdir_p(File.dirname(@output_path))
      FileUtils.mkdir_p(File.dirname(@emit_tex_path)) if @emit_tex_path

      Dir.mktmpdir("jpmd-") do |tmpdir|
        template_path = write_file(tmpdir, "template.tex", render_template)
        preamble_path = write_file(tmpdir, "preamble.tex", render_preamble)
        metadata_path = write_file(tmpdir, "metadata.yml", render_metadata(preamble_path))
        tex_basename = "#{File.basename(@output_path, ".pdf")}.tex"
        tex_path = File.join(tmpdir, tex_basename)

        run_pandoc(template_path: template_path, metadata_path: metadata_path, tex_path: tex_path)
        FileUtils.cp(tex_path, @emit_tex_path) if @emit_tex_path

        2.times { run_lualatex(tex_path, tmpdir) }

        pdf_path = tex_path.sub(/\.tex\z/, ".pdf")
        raise JPMD::CommandError, "Expected PDF was not generated: #{pdf_path}" unless File.file?(pdf_path)

        FileUtils.cp(pdf_path, @output_path)
      end

      @output_path
    end

    private

    def ensure_input_exists
      raise JPMD::ValidationError, "Input file not found: #{@input_path}" unless File.file?(@input_path)
    end

    def render_template
      source = File.read(File.join(APP_ROOT, "template.tex"), mode: "r:utf-8")
      class_options = [
        "lualatex",
        "paper=a4",
        "fontsize=#{@derived.fetch("body_size")}",
        "jafontsize=#{@derived.fetch("body_size")}",
        "line_length=#{@derived.fetch("characters_per_line")}zw",
        "number_of_lines=#{@derived.fetch("lines_per_page")}",
        "baselineskip=#{format_pt(@derived.fetch("baselineskip_pt"))}"
      ].join(",")

      rendered = source.sub(
        /\\documentclass\[[^\n]+\]\{jlreq\}/,
        "\\documentclass[#{class_options}]{jlreq}"
      )

      raise JPMD::CommandError, "Could not find jlreq documentclass line in template.tex" if rendered == source

      rendered
    end

    def render_preamble
      template = File.read(File.join(APP_ROOT, "templates", "preamble.tex.erb"), mode: "r:utf-8")
      layout = @settings.fetch("layout")
      kanbun = @settings.fetch("kanbun")

      ERB.new(template, trim_mode: "-").result_with_hash(
        kanjiskip: format_pt(@derived.fetch("kanjiskip_pt")),
        furigana_size: tex_dimension(kanbun.fetch("furigana").fetch("size")),
        furigana_up: tex_dimension(kanbun.fetch("furigana").fetch("shift").fetch("up")),
        furigana_right: tex_dimension(kanbun.fetch("furigana").fetch("shift").fetch("right")),
        furigana_down: tex_dimension(kanbun.fetch("furigana").fetch("shift").fetch("down")),
        furigana_left: tex_dimension(kanbun.fetch("furigana").fetch("shift").fetch("left")),
        kaeriten_size: tex_dimension(kanbun.fetch("kaeriten").fetch("size")),
        kaeriten_up: tex_dimension(kanbun.fetch("kaeriten").fetch("shift").fetch("up")),
        kaeriten_right: tex_dimension(kanbun.fetch("kaeriten").fetch("shift").fetch("right")),
        kaeriten_down: tex_dimension(kanbun.fetch("kaeriten").fetch("shift").fetch("down")),
        kaeriten_left: tex_dimension(kanbun.fetch("kaeriten").fetch("shift").fetch("left")),
        okurigana_size: tex_dimension(kanbun.fetch("okurigana").fetch("size")),
        okurigana_up: tex_dimension(kanbun.fetch("okurigana").fetch("shift").fetch("up")),
        okurigana_right: tex_dimension(kanbun.fetch("okurigana").fetch("shift").fetch("right")),
        okurigana_down: tex_dimension(kanbun.fetch("okurigana").fetch("shift").fetch("down")),
        okurigana_left: tex_dimension(kanbun.fetch("okurigana").fetch("shift").fetch("left")),
        side_gap: tex_dimension(kanbun.fetch("side").fetch("gap")),
        side_min_width: tex_dimension(kanbun.fetch("side").fetch("min_width")),
        body_size: tex_dimension(layout.fetch("font").fetch("body_size"))
      )
    end

    def render_metadata(preamble_path)
      margins = @settings.fetch("layout").fetch("margins")
      metadata = {
        "geometry" => [
          "top=#{margins.fetch("top")}",
          "bottom=#{margins.fetch("bottom")}",
          "left=#{margins.fetch("left")}",
          "right=#{margins.fetch("right")}"
        ],
        "header-includes" => [
          "\\input{#{tex_path(preamble_path)}}"
        ]
      }

      YAML.dump(metadata)
    end

    def run_pandoc(template_path:, metadata_path:, tex_path:)
      command = [
        resolve_pandoc,
        @input_path,
        "-f", "markdown+bracketed_spans",
        "--standalone",
        "--citeproc",
        "--template", template_path,
        "--metadata-file", metadata_path,
        "--lua-filter", File.join(APP_ROOT, "filter.lua"),
        "-t", "latex",
        "-o", tex_path
      ]

      execute(command, chdir: APP_ROOT, failure_label: "Pandoc")
    end

    def run_lualatex(tex_path, workdir)
      command = [
        resolve_lualatex,
        "-interaction=nonstopmode",
        "-halt-on-error",
        "-file-line-error",
        File.basename(tex_path)
      ]

      execute(command, chdir: workdir, failure_label: "LuaLaTeX")
    end

    def execute(command, chdir:, failure_label:)
      stdout, stderr, status = Open3.capture3(*command, chdir: chdir)
      return if status.success?

      output = [stdout, stderr].reject(&:empty?).join("\n")
      raise JPMD::CommandError, "#{failure_label} failed:\n#{output}"
    end

    def resolve_pandoc
      @pandoc_path ||= resolve_binary(
        env_name: "PANDOC_PATH",
        fallback_paths: [WINDOWS_PANDOC],
        command_name: "pandoc"
      )
    end

    def resolve_lualatex
      @lualatex_path ||= resolve_binary(
        env_name: "LUALATEX_PATH",
        fallback_paths: [WINDOWS_LUALATEX],
        command_name: "lualatex"
      )
    end

    def resolve_binary(env_name:, fallback_paths:, command_name:)
      explicit = ENV[env_name]
      return explicit if explicit && !explicit.empty? && File.exist?(explicit)

      fallback_paths.each do |path|
        return path if File.exist?(path)
      end

      locator = windows? ? "where.exe" : "which"
      stdout, status = Open3.capture2(locator, command_name)
      candidate = stdout.lines.first&.strip
      return candidate if status.success? && candidate && !candidate.empty?

      raise JPMD::CommandError, "Could not find #{command_name}; set #{env_name} or install it on PATH"
    end

    def write_file(dir, name, content)
      path = File.join(dir, name)
      File.write(path, content, mode: "w:utf-8")
      path
    end

    def tex_path(path)
      Pathname(path).to_s.tr("\\", "/")
    end

    def format_pt(value)
      format("%.5fpt", value)
    end

    def tex_dimension(value)
      value.to_s.sub(/zw\z/, "\\\\zw").sub(/zh\z/, "\\\\zh")
    end

    def windows?
      RbConfig::CONFIG["host_os"].match?(/mswin|mingw|cygwin/i)
    end
  end
end
