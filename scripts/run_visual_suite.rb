# frozen_string_literal: true

require "base64"
require "cgi"
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
    html_report_path = File.join(OUTPUT_ROOT, "report.html")
    File.write(report_path, render_report, mode: "w:utf-8")
    File.write(html_report_path, render_html_report, mode: "w:utf-8")
    puts "Wrote #{report_path}"
    puts "Wrote #{html_report_path}"
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
      "default_preset" => "linear",
      "presets" => {
        "linear" => overrides
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

  def render_html_report
    sections = @results.map do |result|
      <<~HTML
        <section class="case" id="#{html_escape(section_id(result))}">
          <h2>#{html_escape(result.fetch("label"))} <span class="status">#{html_escape(result.fetch("status"))}</span></h2>
          <ul>
            <li><strong>Slug:</strong> <code>#{html_escape(result.fetch("slug"))}</code></li>
            <li><strong>Focus:</strong> #{html_escape(result.fetch("focus"))}</li>
            <li><strong>Input:</strong> <code>#{html_escape(result.fetch("input"))}</code></li>
            <li><strong>Expected:</strong> <code>#{html_escape(result.fetch("expected"))}</code></li>
            <li><strong>Config:</strong> <code>#{html_escape(relative_to_root(result.fetch("config_path")))}</code></li>
            #{html_output_paths(result)}
          </ul>
          <h3>Overrides</h3>
          <pre>#{html_escape(YAML.dump(result.fetch("overrides")).strip)}</pre>
          <h3>Command Output</h3>
          <pre>#{html_escape(result.fetch("output"))}</pre>
          #{html_images(result)}
        </section>
      HTML
    end.join("\n")

    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Visual Variation Suite</title>
        <style>
          body { font-family: "Segoe UI", Arial, sans-serif; margin: 24px; line-height: 1.5; }
          h1, h2, h3 { margin-bottom: 0.4em; }
          .summary { margin-bottom: 24px; }
          .toc { background: #fafafa; border: 1px solid #ddd; padding: 16px 20px; margin-bottom: 24px; }
          .toc h2 { margin-top: 0; }
          .toc-group { margin-bottom: 16px; }
          .toc-group:last-child { margin-bottom: 0; }
          .toc ul { margin: 8px 0 0; padding-left: 20px; }
          .toc li { margin: 4px 0; }
          .toc a { color: #0a58ca; text-decoration: none; }
          .toc a:hover { text-decoration: underline; }
          .case { border-top: 1px solid #ccc; padding-top: 20px; margin-top: 20px; }
          .status { font-size: 0.8em; color: #0a6; }
          ul { padding-left: 20px; }
          pre { background: #f5f5f5; border: 1px solid #ddd; padding: 12px; overflow-x: auto; }
          .images { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; }
          figure { margin: 0; }
          img { max-width: 100%; border: 1px solid #ddd; }
          figcaption { font-size: 0.9em; margin-top: 6px; color: #444; word-break: break-all; }
        </style>
      </head>
      <body>
        <h1>Visual Variation Suite</h1>
        <div class="summary">
          <p><strong>Generated at:</strong> #{html_escape(Time.now.to_s)}</p>
          <p><strong>Total cases:</strong> #{@results.length} |
             <strong>Passed:</strong> #{@results.count { |result| result.fetch("status") == "PASS" }} |
             <strong>Failed:</strong> #{@results.count { |result| result.fetch("status") != "PASS" }}</p>
        </div>
        #{html_toc}
        #{sections}
      </body>
      </html>
    HTML
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

  def html_output_paths(result)
    return "" unless result["pdf_path"]

    <<~HTML
      <li><strong>PDF:</strong> <code>#{html_escape(relative_to_root(result.fetch("pdf_path")))}</code></li>
      <li><strong>TeX:</strong> <code>#{html_escape(relative_to_root(result.fetch("tex_path")))}</code></li>
      <li><strong>Page count:</strong> <code>#{result.fetch("page_count")}</code></li>
    HTML
  end

  def html_images(result)
    return "" unless result["page_files"] && !result.fetch("page_files").empty?

    figures = representative_images(result).map do |path|
      <<~HTML
        <figure>
          <img alt="#{html_escape(File.basename(path))}" src="#{image_data_uri(path)}">
          <figcaption>#{html_escape(relative_to_root(path))}</figcaption>
        </figure>
      HTML
    end.join("\n")

    <<~HTML
      <h3>Representative Pages</h3>
      <div class="images">
        #{figures}
      </div>
    HTML
  end

  def html_toc
    groups = @results.group_by { |result| result.fetch("focus") }

    sections = %w[layout kanbun].filter_map do |focus|
      results = groups[focus]
      next if results.nil? || results.empty?

      items = results.map do |result|
        <<~HTML
          <li><a href="##{html_escape(section_id(result))}">#{html_escape(result.fetch("label"))}</a></li>
        HTML
      end.join

      <<~HTML
        <div class="toc-group">
          <h2>#{html_escape(focus.capitalize)}</h2>
          <ul>
            #{items}
          </ul>
        </div>
      HTML
    end

    <<~HTML
      <nav class="toc">
        <h2>Contents</h2>
        #{sections.join("\n")}
      </nav>
    HTML
  end

  def section_id(result)
    "case-#{result.fetch("slug")}"
  end

  def image_data_uri(path)
    "data:image/png;base64,#{Base64.strict_encode64(File.binread(path))}"
  end

  def html_escape(text)
    CGI.escapeHTML(text.to_s)
  end
end

VariationSuite.new.run
