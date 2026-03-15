# frozen_string_literal: true

require "minitest/autorun"
require "tempfile"
require "fileutils"
require "yaml"
require_relative "../lib/jpmd"

module JPMDTestHelper
  def with_temp_markdown(frontmatter = {})
    dir = Dir.mktmpdir("jpmd-test-")
    input_path = File.join(dir, "sample.md")
    config_path = File.join(dir, "jpmd.yml")
    metadata = { "jpmd" => frontmatter }

    File.write(config_path, YAML.dump({}), mode: "w:utf-8")
    File.write(input_path, <<~MARKDOWN, mode: "w:utf-8")
      ---
      #{indent_yaml(metadata)}
      ---

      本文
    MARKDOWN

    yield input_path, config_path
  ensure
    FileUtils.rm_rf(dir) if dir && Dir.exist?(dir)
  end

  def indent_yaml(hash)
    YAML.dump(hash).lines.reject { |line| line.start_with?("---") }.join
  end
end
