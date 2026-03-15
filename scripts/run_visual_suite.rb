# frozen_string_literal: true

require "fileutils"
require "open3"
require "pathname"
require "rbconfig"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CASES_PATH = File.join(ROOT, "test", "variation_suite.yml")
OUTPUT_ROOT = File.join(ROOT, "out", "variation-suite")
PANDOC_PPM_FALLBACK = "C:/texlive/2025/bin/windows/pdftoppm.exe"

class VariationSuite
  def initialize
    @suite = YAML.safe_load(File.read(CASES_PATH, mode: "r:utf-8"), aliases: true)
    @results = []
  end

  def run
    prepare_output_root

    @suite.fetch("cases").each do |test_case|
      run_case(test_case)
    end

    report_path = File.join(OUTPUT_ROOT, "report.md")
    File.write(report_path, render_report, mode: "w:utf-8")
    puts "Wrote #{report_path}"
  end

  private

  def prepare_output_root
    FileUtils.rm_rf(OUTPUT_ROOT) if Dir.exist?(OUTPUT_ROOT)
    FileUtils.mkdir_p(OUTPUT_ROOT)
    %w[configs pdfs tex pages].each do |dir|
      FileUtils.mkdir_p(File.join(OUTPUT_ROOT, dir))
    end
  end

  def run_case(test_case)
    slug = test_case.fetch("slug")
    config_path = File.join(OUTPUT_ROOT, "configs", "#{slug}.yml")
    pdf_path = File.join(OUTPUT_ROOT, "pdfs", "#{slug}.pdf")
    tex_path = File.join(OUTPUT_ROOT, "tex", "#{slug}.tex")
    pages_prefix = File.join(OUTPUT_ROOT, "pages", slug)
    input_path = File.expand_path(test_case.fetch("input"), ROOT)

    FileUtils.rm_f(config_path)
    FileUtils.rm_f(pdf_path)
    FileUtils.rm_f(tex_path)
    Dir["#{pages_prefix}-*.png"].each { |path| FileUtils.rm_f(path) }

    config = build_case_config(test_case.fetch("overrides", {}))
    File.write(config_path, YAML.dump(config), mode: "w:utf-8")

    build_command = [
      ruby_exe,
      File.join(ROOT, "bin", "jpmd"),
      "build",
      input_path,
      "-o",
      pdf_path,
      "--emit-tex",
      tex_path,
      "--config",
      config_path
    ]

    success, output = capture(build_command)
    expected = test_case.fetch("expected", "success")

    if success
      page_files = render_pdf_pages(pdf_path, pages_prefix)
      @results << success_result(test_case, config_path, pdf_path, tex_path, page_files, output, expected)
    else
      @results << failure_result(test_case, config_path, output, expected)
    end
  end

  def build_case_config(overrides)
    {
      "default_preset" => "academic",
      "presets" => {
        "academic" => overrides
      }
    }
  end

  def render_pdf_pages(pdf_path, pages_prefix)
    command = [
      pdftoppm_exe,
      "-png",
      "-r",
      "180",
      pdf_path,
      pages_prefix
    ]

    success, output = capture(command)
    raise "pdftoppm failed for #{pdf_path}:\n#{output}" unless success

    Dir["#{pages_prefix}-*.png"].sort
  end

  def success_result(test_case, config_path, pdf_path, tex_path, page_files, output, expected)
    {
      "slug" => test_case.fetch("slug"),
      "label" => test_case.fetch("label"),
      "input" => test_case.fetch("input"),
      "focus" => test_case.fetch("focus"),
      "expected" => expected,
      "status" => expected == "success" ? "PASS" : "UNEXPECTED PASS",
      "config_path" => config_path,
      "pdf_path" => pdf_path,
      "tex_path" => tex_path,
      "page_files" => page_files,
      "page_count" => page_files.length,
      "output" => output.strip,
      "overrides" => test_case.fetch("overrides", {})
    }
  end

  def failure_result(test_case, config_path, output, expected)
    {
      "slug" => test_case.fetch("slug"),
      "label" => test_case.fetch("label"),
      "input" => test_case.fetch("input"),
      "focus" => test_case.fetch("focus"),
      "expected" => expected,
      "status" => expected == "failure" ? "PASS" : "FAIL",
      "config_path" => config_path,
      "output" => output.strip,
      "overrides" => test_case.fetch("overrides", {})
    }
  end

  def render_report
    lines = []
    lines << "# Visual Variation Suite"
    lines << ""
    lines << "Generated at: #{Time.now}"
    lines << ""
    lines << "- Total cases: `#{@results.length}`"
    lines << "- Passed: `#{@results.count { |result| result.fetch("status") == "PASS" }}`"
    lines << "- Failed: `#{@results.count { |result| result.fetch("status") != "PASS" }}`"
    lines << ""

    @results.each do |result|
      lines << "## #{result.fetch("label")} (`#{result.fetch("status")}`)"
      lines << ""
      lines << "- Slug: `#{result.fetch("slug")}`"
      lines << "- Focus: #{result.fetch("focus")}"
      lines << "- Input: `#{result.fetch("input")}`"
      lines << "- Expected: `#{result.fetch("expected")}`"
      lines << "- Config: `#{relative_to_root(result.fetch("config_path"))}`"

      if result["pdf_path"]
        lines << "- PDF: `#{relative_to_root(result.fetch("pdf_path"))}`"
        lines << "- TeX: `#{relative_to_root(result.fetch("tex_path"))}`"
        lines << "- Page count: `#{result.fetch("page_count")}`"
      end

      lines << ""
      lines << "### Overrides"
      lines << ""
      lines << "```yaml"
      lines << YAML.dump(result.fetch("overrides")).strip
      lines << "```"
      lines << ""
      lines << "### Command Output"
      lines << ""
      lines << "```text"
      lines << result.fetch("output")
      lines << "```"

      if result["page_files"] && !result.fetch("page_files").empty?
        lines << ""
        lines << "### Representative Pages"
        lines << ""
        representative_images(result).each do |path|
          lines << "![#{File.basename(path)}](#{File.expand_path(path).tr("\\", "/")})"
          lines << ""
        end
      end
    end

    lines.join("\n")
  end

  def representative_images(result)
    pages = result.fetch("page_files")
    return [pages.first].compact if result.fetch("focus") == "kanbun"

    images = [pages.first, pages.last].compact
    images.uniq
  end

  def capture(command)
    stdout, stderr, status = Open3.capture3(*command, chdir: ROOT)
    [status.success?, [stdout, stderr].reject(&:empty?).join("\n")]
  end

  def ruby_exe
    RbConfig.ruby
  end

  def pdftoppm_exe
    @pdftoppm_exe ||= begin
      explicit = ENV["PDFTOPPM_PATH"]
      return explicit if explicit && File.exist?(explicit)
      return PANDOC_PPM_FALLBACK if File.exist?(PANDOC_PPM_FALLBACK)

      locator = windows? ? "where.exe" : "which"
      stdout, _stderr, status = Open3.capture3(locator, "pdftoppm")
      candidate = stdout.lines.first&.strip
      raise "Could not find pdftoppm; set PDFTOPPM_PATH" unless status.success? && candidate && !candidate.empty?

      candidate
    end
  end

  def windows?
    RbConfig::CONFIG["host_os"].match?(/mswin|mingw|cygwin/i)
  end

  def relative_to_root(path)
    Pathname(path).relative_path_from(Pathname(ROOT)).to_s.tr("\\", "/")
  end
end

VariationSuite.new.run
