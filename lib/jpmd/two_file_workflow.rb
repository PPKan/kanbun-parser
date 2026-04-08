# frozen_string_literal: true

require "tmpdir"
require "yaml"

module JPMD
  class TwoFileWorkflow
    DEFAULT_PRESET_NAME = "academic"
    DEFAULT_CSL_PATH = File.expand_path("../../references/word-japanese-note.csl", __dir__)

    def initialize(markdown_path:, bibliography_path:, output_path:, config_path:, preset_name:, emit_tex_path:, csl_path: DEFAULT_CSL_PATH, compiler_class: JPMD::Compiler)
      @markdown_path = File.expand_path(markdown_path)
      @bibliography_path = File.expand_path(bibliography_path)
      @output_path = File.expand_path(output_path)
      @config_path = File.expand_path(config_path)
      @preset_name = preset_name || DEFAULT_PRESET_NAME
      @emit_tex_path = emit_tex_path && File.expand_path(emit_tex_path)
      @csl_path = csl_path && File.expand_path(csl_path)
      @compiler_class = compiler_class
    end

    def build
      ensure_file_exists(@markdown_path, "Markdown")
      ensure_file_exists(@bibliography_path, "Bibliography")
      ensure_file_exists(@csl_path, "CSL style") if @csl_path

      Dir.mktmpdir("jpmd-two-file-") do |tmpdir|
        merged_input_path = File.join(tmpdir, File.basename(@markdown_path))
        File.write(merged_input_path, merged_markdown, mode: "w:utf-8")

        @compiler_class.new(
          input_path: merged_input_path,
          output_path: @output_path,
          config_path: @config_path,
          preset_name: @preset_name,
          emit_tex_path: @emit_tex_path
        ).build
      end
    end

    private

    def ensure_file_exists(path, label)
      raise JPMD::ValidationError, "#{label} file not found: #{path}" unless File.file?(path)
    end

    def merged_markdown
      metadata, body = split_frontmatter(read_markdown)
      metadata["bibliography"] = @bibliography_path
      metadata["csl"] = @csl_path if @csl_path

      frontmatter = YAML.dump(stringify_keys(metadata)).sub(/\A---\n/, "")
      +"---\n#{frontmatter}---\n\n#{body}"
    end

    def read_markdown
      File.read(@markdown_path, mode: "r:utf-8").sub(/\A\uFEFF/, "")
    end

    def split_frontmatter(content)
      match = content.match(/\A---\s*\r?\n(.*?)\r?\n(?:---|\.\.\.)\s*(?:\r?\n|$)/m)
      return [{}, content] unless match

      metadata = JPMD.safe_yaml_load(match[1])
      raise JPMD::ValidationError, "YAML frontmatter in #{@markdown_path} must decode to a mapping" unless metadata.is_a?(Hash)

      [metadata, content[match[0].length..] || ""]
    rescue Psych::SyntaxError => e
      raise JPMD::ValidationError, "Invalid YAML frontmatter in #{@markdown_path}: #{e.message}"
    end

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), result|
          result[key.to_s] = stringify_keys(nested_value)
        end
      when Array
        value.map { |item| stringify_keys(item) }
      else
        value
      end
    end
  end
end
