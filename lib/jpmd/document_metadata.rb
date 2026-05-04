# frozen_string_literal: true

require "pathname"
require "yaml"

module JPMD
  class DocumentMetadata
    CONFIG_REFERENCE_KEY = "config"
    JPMD_SETTING_KEYS = %w[preset output layout kanbun].freeze
    PATH_METADATA_KEYS = %w[bibliography csl].freeze

    def self.load(path)
      new(path).load
    end

    def initialize(path)
      @path = File.expand_path(path)
      @stack = []
    end

    def load
      metadata = load_frontmatter(@path)
      resolve_metadata(metadata, source_path: @path, allow_jpmd_shortform: false)
    end

    private

    def load_frontmatter(path)
      content = File.read(path, mode: "r:utf-8").sub(/\A\uFEFF/, "")
      match = content.match(/\A---\s*\r?\n(.*?)\r?\n(?:---|\.\.\.)\s*(?:\r?\n|$)/m)
      return {} unless match

      load_yaml_string(match[1], "YAML frontmatter in #{path}")
    rescue Psych::SyntaxError => e
      raise JPMD::ValidationError, "Invalid YAML frontmatter in #{path}: #{e.message}"
    end

    def load_referenced_yaml(path)
      raise JPMD::ValidationError, "Referenced YAML file not found: #{path}" unless File.file?(path)

      content = File.read(path, mode: "r:utf-8").sub(/\A\uFEFF/, "")
      load_yaml_string(content, "Referenced YAML in #{path}")
    rescue Psych::SyntaxError => e
      raise JPMD::ValidationError, "Invalid referenced YAML in #{path}: #{e.message}"
    end

    def load_yaml_string(content, label)
      metadata = JPMD.safe_yaml_load(content)
      raise JPMD::ValidationError, "#{label} must decode to a mapping" unless metadata.is_a?(Hash)

      normalize_hash(metadata)
    end

    def resolve_metadata(metadata, source_path:, allow_jpmd_shortform:)
      metadata = normalize_jpmd_shortform(metadata) if allow_jpmd_shortform
      jpmd = metadata["jpmd"]
      return normalize_metadata_paths(metadata, source_path) if jpmd.nil?

      raise JPMD::ValidationError, "jpmd frontmatter in #{source_path} must decode to a mapping" unless jpmd.is_a?(Hash)

      referenced = load_references(jpmd.delete(CONFIG_REFERENCE_KEY), source_path)
      deep_merge(referenced, normalize_metadata_paths(metadata, source_path))
    end

    def load_references(value, source_path)
      references = reference_paths(value, source_path)

      references.reduce({}) do |merged, path|
        deep_merge(merged, load_reference(path))
      end
    end

    def load_reference(path)
      if @stack.include?(path)
        cycle = (@stack + [path]).map { |item| Pathname(item).basename.to_s }.join(" -> ")
        raise JPMD::ValidationError, "Cyclic jpmd.config reference: #{cycle}"
      end

      @stack << path
      metadata = load_referenced_yaml(path)
      resolve_metadata(metadata, source_path: path, allow_jpmd_shortform: true)
    ensure
      @stack.pop if @stack.last == path
    end

    def reference_paths(value, source_path)
      case value
      when nil
        []
      when String
        [expand_path(value, source_path)]
      when Array
        value.map do |entry|
          raise JPMD::ValidationError, "jpmd.config entries must be strings" unless entry.is_a?(String)

          expand_path(entry, source_path)
        end
      else
        raise JPMD::ValidationError, "jpmd.config must be a string or list of strings"
      end
    end

    def normalize_jpmd_shortform(metadata)
      jpmd_values = {}
      normalized = metadata.each_with_object({}) do |(key, value), hash|
        if JPMD_SETTING_KEYS.include?(key)
          jpmd_values[key] = value
        else
          hash[key] = value
        end
      end

      return normalized if jpmd_values.empty?

      normalized["jpmd"] = deep_merge(normalized.fetch("jpmd", {}), jpmd_values)
      normalized
    end

    def normalize_metadata_paths(metadata, source_path)
      normalized = normalize_hash(metadata)

      PATH_METADATA_KEYS.each do |key|
        normalized[key] = expand_path_value(normalized[key], source_path) if normalized.key?(key)
      end

      jpmd = normalized["jpmd"]
      if jpmd.is_a?(Hash) && jpmd["output"].is_a?(Hash)
        jpmd["output"] = jpmd["output"].transform_values do |value|
          value.is_a?(String) && !value.empty? ? expand_path(value, source_path) : value
        end
      end

      normalized
    end

    def expand_path_value(value, source_path)
      case value
      when String
        return value if value.empty?

        expand_path(value, source_path)
      when Array
        value.map do |entry|
          entry.is_a?(String) && !entry.empty? ? expand_path(entry, source_path) : entry
        end
      else
        value
      end
    end

    def expand_path(path, source_path)
      return path if Pathname(path).absolute?

      File.expand_path(path, File.dirname(source_path))
    end

    def normalize_hash(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), hash|
          hash[key.to_s] = normalize_hash(nested_value)
        end
      when Array
        value.map { |item| normalize_hash(item) }
      else
        value
      end
    end

    def deep_merge(base, override)
      merged = normalize_hash(base)

      normalize_hash(override).each do |key, value|
        merged[key] =
          if merged[key].is_a?(Hash) && value.is_a?(Hash)
            deep_merge(merged[key], value)
          else
            value
          end
      end

      merged
    end
  end
end
