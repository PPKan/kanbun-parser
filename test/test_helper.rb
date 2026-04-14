# frozen_string_literal: true

require "minitest/autorun"
require "tempfile"
require "fileutils"
require "yaml"
require_relative "../lib/jpmd"

module JPMDTestHelper
  def with_temp_markdown(frontmatter = {}, metadata: {}, body: "本文\n")
    dir = Dir.mktmpdir("jpmd-test-")
    input_path = File.join(dir, "sample.md")
    config_path = File.join(dir, "jpmd.yml")
    if frontmatter.is_a?(String)
      body = frontmatter
      frontmatter = {}
    end

    combined_metadata = stringify_keys(metadata)
    combined_metadata["jpmd"] = stringify_keys(frontmatter) unless frontmatter.nil? || frontmatter.empty?

    File.write(config_path, YAML.dump({}), mode: "w:utf-8")
    File.write(input_path, render_markdown(combined_metadata, body), mode: "w:utf-8")

    yield input_path, config_path
  ensure
    FileUtils.rm_rf(dir) if dir && Dir.exist?(dir)
  end

  def render_markdown(metadata, body)
    return body unless metadata && !metadata.empty?

    <<~MARKDOWN
      ---
      #{indent_yaml(metadata)}
      ---

      #{body}
    MARKDOWN
  end

  def indent_yaml(hash)
    YAML.dump(hash).lines.reject { |line| line.start_with?("---") }.join
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
