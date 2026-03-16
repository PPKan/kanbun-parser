# frozen_string_literal: true

require "yaml"

module JPMD
  class WebForm
    DEFAULT_SOURCE_MODE = "paste"
    MAX_UPLOAD_BYTES = 512 * 1024
    ALLOWED_UPLOAD_EXTENSIONS = %w[.md .markdown].freeze
    ALLOWED_UPLOAD_TYPES = %w[text/markdown text/plain].freeze

    class << self
      def default_state(repo_root:)
        {
          "source_mode" => DEFAULT_SOURCE_MODE,
          "markdown_text" => "",
          "upload_filename" => nil,
          "overrides" => build_default_overrides(repo_root)
        }
      end

      def state_from_params(repo_root:, params:)
        state = default_state(repo_root: repo_root)
        state["source_mode"] = source_mode_from(params["source_mode"])
        state["markdown_text"] = params["markdown_text"].to_s
        state["upload_filename"] = uploaded_filename(params["markdown_file"])
        state["overrides"] = merge_nested_hashes(state.fetch("overrides"), normalize_hash(params["overrides"] || {}))
        state
      end

      def extract_source!(params)
        source_mode = source_mode_from(params["source_mode"])

        return extract_pasted_source(params) if source_mode == "paste"

        extract_uploaded_source(params["markdown_file"])
      end

      def sanitize_overrides(overrides)
        compact_value(normalize_hash(overrides || {})) || {}
      end

      private

      def extract_pasted_source(params)
        content = params["markdown_text"].to_s
        raise JPMD::ValidationError, "Paste Markdown is selected, but the textarea is empty." if content.strip.empty?

        {
          "mode" => "paste",
          "filename" => "document.md",
          "content" => content
        }
      end

      def extract_uploaded_source(upload)
        filename = uploaded_filename(upload)
        raise JPMD::ValidationError, "Upload Markdown File is selected, but no file was provided." if filename.to_s.empty?

        extension = File.extname(filename).downcase
        unless ALLOWED_UPLOAD_EXTENSIONS.include?(extension)
          raise JPMD::ValidationError, "Uploaded file must end in .md or .markdown."
        end

        content_type = upload_type(upload)
        unless content_type.empty? || content_type == "application/octet-stream" || ALLOWED_UPLOAD_TYPES.include?(content_type)
          raise JPMD::ValidationError, "Uploaded file must use text/markdown or text/plain."
        end

        tempfile = upload_tempfile(upload)
        raise JPMD::ValidationError, "Upload could not be read." unless tempfile

        raw = tempfile.read.to_s
        tempfile.rewind if tempfile.respond_to?(:rewind)

        raise JPMD::ValidationError, "Uploaded file is empty." if raw.empty?
        raise JPMD::ValidationError, "Uploaded file exceeds 512 KB." if raw.bytesize > MAX_UPLOAD_BYTES

        content = raw.dup.force_encoding(Encoding::UTF_8)
        raise JPMD::ValidationError, "Uploaded file must be valid UTF-8 text." unless content.valid_encoding?
        raise JPMD::ValidationError, "Uploaded file is empty." if content.strip.empty?

        {
          "mode" => "upload",
          "filename" => filename,
          "content" => content
        }
      end

      def build_default_overrides(repo_root)
        config_path = File.join(repo_root, "jpmd.yml")
        project_config =
          if File.file?(config_path)
            YAML.safe_load(File.read(config_path, mode: "r:utf-8"), aliases: true) || {}
          else
            {}
          end

        project_config = normalize_hash(project_config)
        preset_name = project_config["default_preset"].to_s
        preset_name = "academic" if preset_name.empty?

        builtin = normalize_hash(JPMD::Config::BUILTIN_PRESETS.fetch(preset_name))
        project_preset = normalize_hash(project_config.dig("presets", preset_name) || {})
        merged = merge_nested_hashes(builtin, project_preset)

        {
          "layout" => merged.fetch("layout"),
          "kanbun" => merged.fetch("kanbun")
        }
      rescue Psych::SyntaxError => e
        raise JPMD::ValidationError, "Invalid YAML in #{config_path}: #{e.message}"
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

      def merge_nested_hashes(base, override)
        base.each_with_object({}) do |(key, value), hash|
          hash[key] = value
        end.tap do |merged|
          override.each do |key, value|
            merged[key] =
              if merged[key].is_a?(Hash) && value.is_a?(Hash)
                merge_nested_hashes(merged[key], value)
              else
                value
              end
          end
        end
      end

      def compact_value(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested_value), hash|
            compacted = compact_value(nested_value)
            hash[key] = compacted unless compacted.nil? || compacted == {}
          end
        when String
          stripped = value.strip
          stripped.empty? ? nil : stripped
        else
          value
        end
      end

      def uploaded_filename(upload)
        fetch_upload_value(upload, :filename).to_s
      end

      def upload_type(upload)
        fetch_upload_value(upload, :type).to_s
      end

      def upload_tempfile(upload)
        fetch_upload_value(upload, :tempfile)
      end

      def fetch_upload_value(upload, key)
        return nil unless upload.is_a?(Hash)

        upload[key] || upload[key.to_s]
      end

      def source_mode_from(value)
        value.to_s == "upload" ? "upload" : DEFAULT_SOURCE_MODE
      end
    end
  end
end
