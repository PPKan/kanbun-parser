# frozen_string_literal: true

require "yaml"

module JPMD
  class WebForm
    DEFAULT_SOURCE_MODE = "sample"
    DEFAULT_SOURCE_SAMPLE = "academic-paper"
    DEFAULT_BIBLIOGRAPHY_MODE = "sample"
    DEFAULT_BIBLIOGRAPHY_SAMPLE = "zotero-json"
    DEFAULT_CSL_MODE = "sample"
    DEFAULT_CSL_SAMPLE = "chicago-notes"
    MAX_UPLOAD_BYTES = 512 * 1024
    MAX_REFERENCE_UPLOAD_BYTES = 2 * 1024 * 1024
    MARKDOWN_UPLOAD_EXTENSIONS = %w[.md .markdown].freeze
    MARKDOWN_UPLOAD_TYPES = %w[text/markdown text/plain].freeze
    BIBLIOGRAPHY_UPLOAD_EXTENSIONS = %w[.json .bib].freeze
    BIBLIOGRAPHY_UPLOAD_TYPES = %w[application/json text/plain text/x-bibtex application/x-bibtex].freeze
    CSL_UPLOAD_EXTENSIONS = %w[.csl].freeze
    CSL_UPLOAD_TYPES = %w[text/plain text/xml application/xml].freeze

    SOURCE_SAMPLES = {
      "academic-paper" => {
        "label" => "Academic Paper",
        "path" => "examples/academic-paper.md",
        "description" => "Full paper sample with headings, citations, and kanbun markup."
      },
      "minimal-kanbun" => {
        "label" => "Minimal Kanbun",
        "path" => "examples/minimal-kanbun.md",
        "description" => "Smallest bundled sample for quick kanbun-only checks."
      },
      "kanbun-visual" => {
        "label" => "Kanbun Visual Fixture",
        "path" => "test/fixtures/kanbun-visual.md",
        "description" => "Stress case for furigana, kaeriten, and okurigana positioning."
      }
    }.freeze

    BIBLIOGRAPHY_SAMPLES = {
      "zotero-json" => {
        "label" => "General Zotero JSON",
        "workspace_path" => "references/zotero-export.json",
        "note" => "Default general-purpose bundled Zotero export."
      },
      "zotero-bib" => {
        "label" => "General BibTeX",
        "workspace_path" => "references/zotero-export.bib",
        "note" => "Bundled BibTeX sample generated for browser testing."
      },
      "custom-japanese-json" => {
        "label" => "Custom Japanese JSON",
        "workspace_path" => "references/custom/japanese-note-sample.json",
        "note" => "Older project-specific sample kept for comparison."
      },
      "custom-japanese-bib" => {
        "label" => "Custom Japanese BibTeX",
        "workspace_path" => "references/custom/japanese-note-sample.bib",
        "note" => "Older project-specific BibTeX sample kept for comparison."
      }
    }.freeze

    CSL_SAMPLES = {
      "chicago-notes" => {
        "label" => "Chicago Notes Bibliography",
        "workspace_path" => "references/chicago-notes-bibliography.csl",
        "note" => "Default general-purpose CSL for bundled browser tests."
      },
      "custom-japanese-note" => {
        "label" => "Custom Japanese Note",
        "workspace_path" => "references/custom/word-japanese-note.csl",
        "note" => "Older project-specific CSL kept as a reference style."
      }
    }.freeze

    class << self
      def source_samples
        SOURCE_SAMPLES
      end

      def bibliography_samples
        BIBLIOGRAPHY_SAMPLES
      end

      def csl_samples
        CSL_SAMPLES
      end

      def selected_source_sample(key)
        SOURCE_SAMPLES.fetch(normalized_sample_key(key, SOURCE_SAMPLES, DEFAULT_SOURCE_SAMPLE))
      end

      def selected_bibliography_sample(key)
        BIBLIOGRAPHY_SAMPLES.fetch(normalized_sample_key(key, BIBLIOGRAPHY_SAMPLES, DEFAULT_BIBLIOGRAPHY_SAMPLE))
      end

      def selected_csl_sample(key)
        CSL_SAMPLES.fetch(normalized_sample_key(key, CSL_SAMPLES, DEFAULT_CSL_SAMPLE))
      end

      def default_state(repo_root:)
        {
          "source_mode" => DEFAULT_SOURCE_MODE,
          "source_sample" => DEFAULT_SOURCE_SAMPLE,
          "markdown_text" => "",
          "upload_filename" => nil,
          "bibliography_mode" => DEFAULT_BIBLIOGRAPHY_MODE,
          "bibliography_sample" => DEFAULT_BIBLIOGRAPHY_SAMPLE,
          "bibliography_upload_filename" => nil,
          "csl_mode" => DEFAULT_CSL_MODE,
          "csl_sample" => DEFAULT_CSL_SAMPLE,
          "csl_upload_filename" => nil,
          "overrides" => build_default_overrides(repo_root)
        }
      end

      def state_from_params(repo_root:, params:)
        state = default_state(repo_root: repo_root)
        state["source_mode"] = source_mode_from(params["source_mode"])
        state["source_sample"] = normalized_sample_key(params["source_sample"], SOURCE_SAMPLES, DEFAULT_SOURCE_SAMPLE)
        state["markdown_text"] = params["markdown_text"].to_s
        state["upload_filename"] = uploaded_filename(params["markdown_file"])
        state["bibliography_mode"] = bibliography_mode_from(params["bibliography_mode"])
        state["bibliography_sample"] = normalized_sample_key(params["bibliography_sample"], BIBLIOGRAPHY_SAMPLES, DEFAULT_BIBLIOGRAPHY_SAMPLE)
        state["bibliography_upload_filename"] = uploaded_filename(params["bibliography_file"])
        state["csl_mode"] = csl_mode_from(params["csl_mode"])
        state["csl_sample"] = normalized_sample_key(params["csl_sample"], CSL_SAMPLES, DEFAULT_CSL_SAMPLE)
        state["csl_upload_filename"] = uploaded_filename(params["csl_file"])
        state["overrides"] = merge_nested_hashes(state.fetch("overrides"), normalize_hash(params["overrides"] || {}))
        state
      end

      def extract_source!(repo_root:, params:)
        source_mode = source_mode_from(params["source_mode"])

        case source_mode
        when "sample"
          extract_sample_source(repo_root, params["source_sample"])
        when "paste"
          extract_pasted_source(params)
        else
          extract_uploaded_source(params["markdown_file"])
        end
      end

      def resolve_bibliography!(params:)
        resolve_reference_asset(
          mode: bibliography_mode_from(params["bibliography_mode"]),
          sample_key: params["bibliography_sample"],
          sample_map: BIBLIOGRAPHY_SAMPLES,
          default_sample_key: DEFAULT_BIBLIOGRAPHY_SAMPLE,
          upload: params["bibliography_file"],
          upload_kind: "bibliography",
          allowed_extensions: BIBLIOGRAPHY_UPLOAD_EXTENSIONS,
          allowed_types: BIBLIOGRAPHY_UPLOAD_TYPES,
          max_bytes: MAX_REFERENCE_UPLOAD_BYTES,
          invalid_extension_message: "Bibliography upload must end in .json or .bib.",
          invalid_type_message: "Bibliography upload must use JSON, BibTeX, or plain text.",
          missing_upload_message: "Upload Bibliography is selected, but no bibliography file was provided.",
          empty_upload_message: "Uploaded bibliography file is empty.",
          oversized_upload_message: "Uploaded bibliography file exceeds 2 MB.",
          invalid_encoding_message: "Uploaded bibliography file must be valid UTF-8 text."
        )
      end

      def resolve_csl!(params:)
        resolve_reference_asset(
          mode: csl_mode_from(params["csl_mode"]),
          sample_key: params["csl_sample"],
          sample_map: CSL_SAMPLES,
          default_sample_key: DEFAULT_CSL_SAMPLE,
          upload: params["csl_file"],
          upload_kind: "csl",
          allowed_extensions: CSL_UPLOAD_EXTENSIONS,
          allowed_types: CSL_UPLOAD_TYPES,
          max_bytes: MAX_REFERENCE_UPLOAD_BYTES,
          invalid_extension_message: "CSL upload must end in .csl.",
          invalid_type_message: "CSL upload must use XML or plain text.",
          missing_upload_message: "Upload CSL is selected, but no CSL file was provided.",
          empty_upload_message: "Uploaded CSL file is empty.",
          oversized_upload_message: "Uploaded CSL file exceeds 2 MB.",
          invalid_encoding_message: "Uploaded CSL file must be valid UTF-8 text."
        )
      end

      def sanitize_overrides(overrides)
        compact_value(normalize_hash(overrides || {})) || {}
      end

      private

      def extract_sample_source(repo_root, sample_key)
        sample = selected_source_sample(sample_key)
        path = File.join(repo_root, sample.fetch("path"))
        content = File.read(path, mode: "r:utf-8")

        {
          "mode" => "sample",
          "filename" => File.basename(path),
          "content" => content,
          "sample_key" => normalized_sample_key(sample_key, SOURCE_SAMPLES, DEFAULT_SOURCE_SAMPLE)
        }
      end

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
        filename, content = read_uploaded_text(
          upload: upload,
          allowed_extensions: MARKDOWN_UPLOAD_EXTENSIONS,
          allowed_types: MARKDOWN_UPLOAD_TYPES,
          max_bytes: MAX_UPLOAD_BYTES,
          invalid_extension_message: "Uploaded file must end in .md or .markdown.",
          invalid_type_message: "Uploaded file must use text/markdown or text/plain.",
          missing_upload_message: "Upload Markdown File is selected, but no file was provided.",
          empty_upload_message: "Uploaded file is empty.",
          oversized_upload_message: "Uploaded file exceeds 512 KB.",
          invalid_encoding_message: "Uploaded file must be valid UTF-8 text."
        )

        {
          "mode" => "upload",
          "filename" => filename,
          "content" => content
        }
      end

      def resolve_reference_asset(mode:, sample_key:, sample_map:, default_sample_key:, upload:, upload_kind:, allowed_extensions:, allowed_types:, max_bytes:, invalid_extension_message:, invalid_type_message:, missing_upload_message:, empty_upload_message:, oversized_upload_message:, invalid_encoding_message:)
        case mode
        when "keep"
          nil
        when "sample"
          sample = sample_map.fetch(normalized_sample_key(sample_key, sample_map, default_sample_key))
          {
            "mode" => "sample",
            "kind" => upload_kind,
            "workspace_path" => sample.fetch("workspace_path")
          }
        else
          filename, content = read_uploaded_text(
            upload: upload,
            allowed_extensions: allowed_extensions,
            allowed_types: allowed_types,
            max_bytes: max_bytes,
            invalid_extension_message: invalid_extension_message,
            invalid_type_message: invalid_type_message,
            missing_upload_message: missing_upload_message,
            empty_upload_message: empty_upload_message,
            oversized_upload_message: oversized_upload_message,
            invalid_encoding_message: invalid_encoding_message
          )

          {
            "mode" => "upload",
            "kind" => upload_kind,
            "filename" => filename,
            "content" => content
          }
        end
      end

      def read_uploaded_text(upload:, allowed_extensions:, allowed_types:, max_bytes:, invalid_extension_message:, invalid_type_message:, missing_upload_message:, empty_upload_message:, oversized_upload_message:, invalid_encoding_message:)
        filename = uploaded_filename(upload)
        raise JPMD::ValidationError, missing_upload_message if filename.to_s.empty?

        extension = File.extname(filename).downcase
        raise JPMD::ValidationError, invalid_extension_message unless allowed_extensions.include?(extension)

        content_type = upload_type(upload)
        unless content_type.empty? || content_type == "application/octet-stream" || allowed_types.include?(content_type)
          raise JPMD::ValidationError, invalid_type_message
        end

        tempfile = upload_tempfile(upload)
        raise JPMD::ValidationError, "Upload could not be read." unless tempfile

        raw = tempfile.read.to_s
        tempfile.rewind if tempfile.respond_to?(:rewind)

        raise JPMD::ValidationError, empty_upload_message if raw.empty?
        raise JPMD::ValidationError, oversized_upload_message if raw.bytesize > max_bytes

        content = raw.dup.force_encoding(Encoding::UTF_8)
        raise JPMD::ValidationError, invalid_encoding_message unless content.valid_encoding?
        raise JPMD::ValidationError, empty_upload_message if content.strip.empty?

        [filename, content]
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
        case value.to_s
        when "paste", "upload"
          value.to_s
        else
          DEFAULT_SOURCE_MODE
        end
      end

      def bibliography_mode_from(value)
        case value.to_s
        when "upload", "keep"
          value.to_s
        else
          DEFAULT_BIBLIOGRAPHY_MODE
        end
      end

      def csl_mode_from(value)
        case value.to_s
        when "upload", "keep"
          value.to_s
        else
          DEFAULT_CSL_MODE
        end
      end

      def normalized_sample_key(value, collection, default_key)
        key = value.to_s
        collection.key?(key) ? key : default_key
      end
    end
  end
end
