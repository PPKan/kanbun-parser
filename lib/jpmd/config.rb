# frozen_string_literal: true

require "yaml"

module JPMD
  class Config
    A4_WIDTH_PT = 210.0 * 72.27 / 25.4
    A4_HEIGHT_PT = 297.0 * 72.27 / 25.4

    BUILTIN_PRESETS = {
      "academic" => {
        "layout" => {
          "margins" => {
            "top" => "2.5cm",
            "right" => "3cm",
            "bottom" => "2.5cm",
            "left" => "3cm"
          },
          "grid" => {
            "characters_per_line" => 30,
            "lines_per_page" => 30
          },
          "font" => {
            "body_size" => "12pt"
          }
        },
        "kanbun" => {
          "side" => {
            "gap" => "0.10zw",
            "min_width" => "0.35zw"
          },
          "furigana" => {
            "size" => "7pt",
            "shift" => {
              "up" => "0pt",
              "right" => "0pt",
              "down" => "0pt",
              "left" => "0pt"
            }
          },
          "kaeriten" => {
            "size" => "7pt",
            "shift" => {
              "up" => "0pt",
              "right" => "0pt",
              "down" => "0.35ex",
              "left" => "0pt"
            }
          },
          "okurigana" => {
            "size" => "7pt",
            "shift" => {
              "up" => "0pt",
              "right" => "0pt",
              "down" => "0pt",
              "left" => "0pt"
            }
          }
        }
      }
    }.freeze

    PROJECT_DEFAULTS = {
      "default_preset" => "academic",
      "presets" => {}
    }.freeze

    PHYSICAL_UNIT_FACTORS = {
      "pt" => 1.0,
      "mm" => 72.27 / 25.4,
      "cm" => 72.27 / 2.54,
      "in" => 72.27
    }.freeze

    PHYSICAL_DIMENSION_PATTERN = /\A(0|[0-9]+(?:\.[0-9]+)?)(pt|mm|cm|in)\z/
    GENERIC_DIMENSION_PATTERN = /\A(0|[0-9]+(?:\.[0-9]+)?)(pt|mm|cm|in|bp|dd|cc|sp|ex|em|zw|zh)\z/

    def initialize(input_path:, config_path:, cli_preset:, runtime_overrides: nil)
      @input_path = input_path
      @config_path = config_path
      @cli_preset = cli_preset
      @runtime_overrides = runtime_overrides || {}
    end

    def resolve
      project_config = load_project_config
      document_config = load_document_config

      preset_name = @cli_preset ||
        string_or_nil(document_config.delete("preset")) ||
        string_or_nil(project_config["default_preset"]) ||
        PROJECT_DEFAULTS["default_preset"]

      builtin_preset = BUILTIN_PRESETS[preset_name]
      raise JPMD::ValidationError, "Unknown preset: #{preset_name}" unless builtin_preset

      project_preset = hash_at(project_config, "presets", preset_name) || {}
      merged = deep_merge(builtin_preset, project_preset)
      merged = deep_merge(merged, document_config)
      merged = deep_merge(merged, @runtime_overrides)

      {
        "preset_name" => preset_name,
        "project_root" => project_root,
        "settings" => merged,
        "derived" => validate_and_derive(merged)
      }
    end

    private

    def load_project_config
      config_hash =
        if File.file?(@config_path)
          normalize_hash(load_yaml_file(@config_path))
        else
          {}
        end

      deep_merge(PROJECT_DEFAULTS, config_hash)
    end

    def load_document_config
      metadata = extract_frontmatter(@input_path)
      normalize_hash(metadata.fetch("jpmd", {}))
    end

    def load_yaml_file(path)
      content = File.read(path, mode: "r:utf-8")
      YAML.safe_load(content, aliases: true) || {}
    rescue Psych::SyntaxError => e
      raise JPMD::ValidationError, "Invalid YAML in #{path}: #{e.message}"
    end

    def extract_frontmatter(path)
      content = File.read(path, mode: "r:utf-8").sub(/\A\uFEFF/, "")
      match = content.match(/\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|$)/m)
      return {} unless match

      YAML.safe_load(match[1], aliases: true) || {}
    rescue Psych::SyntaxError => e
      raise JPMD::ValidationError, "Invalid YAML frontmatter in #{path}: #{e.message}"
    end

    def validate_and_derive(settings)
      layout = fetch_hash(settings, "layout")
      margins = fetch_hash(layout, "margins")
      grid = fetch_hash(layout, "grid")
      font = fetch_hash(layout, "font")
      kanbun = fetch_hash(settings, "kanbun")

      top_pt = parse_physical_dimension(fetch_required(margins, "top"), "layout.margins.top")
      right_pt = parse_physical_dimension(fetch_required(margins, "right"), "layout.margins.right")
      bottom_pt = parse_physical_dimension(fetch_required(margins, "bottom"), "layout.margins.bottom")
      left_pt = parse_physical_dimension(fetch_required(margins, "left"), "layout.margins.left")
      body_size_pt = parse_physical_dimension(fetch_required(font, "body_size"), "layout.font.body_size")

      characters_per_line = parse_positive_integer(fetch_required(grid, "characters_per_line"), "layout.grid.characters_per_line", minimum: 2)
      lines_per_page = parse_positive_integer(fetch_required(grid, "lines_per_page"), "layout.grid.lines_per_page", minimum: 1)

      validate_kanbun_dimensions(kanbun)

      text_width_pt = A4_WIDTH_PT - left_pt - right_pt
      text_height_pt = A4_HEIGHT_PT - top_pt - bottom_pt

      raise JPMD::ValidationError, "Margins leave no usable text width on A4 paper" unless text_width_pt.positive?
      raise JPMD::ValidationError, "Margins leave no usable text height on A4 paper" unless text_height_pt.positive?

      kanjiskip_pt = (text_width_pt - (characters_per_line * body_size_pt)) / (characters_per_line - 1)
      raise JPMD::ValidationError, "Layout requires negative kanjiskip; reduce font size, widen the text block, or lower characters_per_line" if kanjiskip_pt.negative?

      baselineskip_pt = text_height_pt / lines_per_page
      raise JPMD::ValidationError, "Layout requires nonpositive baselineskip" unless baselineskip_pt.positive?

      {
        "characters_per_line" => characters_per_line,
        "lines_per_page" => lines_per_page,
        "body_size" => fetch_required(font, "body_size"),
        "kanjiskip_pt" => kanjiskip_pt,
        "baselineskip_pt" => baselineskip_pt
      }
    end

    def validate_kanbun_dimensions(kanbun)
      side = fetch_hash(kanbun, "side")
      validate_non_negative_dimension(fetch_required(side, "gap"), "kanbun.side.gap")
      validate_non_negative_dimension(fetch_required(side, "min_width"), "kanbun.side.min_width")

      %w[furigana kaeriten okurigana].each do |name|
        annotation = fetch_hash(kanbun, name)
        validate_positive_dimension(fetch_required(annotation, "size"), "kanbun.#{name}.size")
        shift = fetch_hash(annotation, "shift")

        %w[up right down left].each do |direction|
          validate_non_negative_dimension(fetch_required(shift, direction), "kanbun.#{name}.shift.#{direction}")
        end
      end
    end

    def parse_physical_dimension(value, path)
      string = string_or_nil(value)
      match = string&.match(PHYSICAL_DIMENSION_PATTERN)
      raise JPMD::ValidationError, "#{path} must be a dimension in pt, mm, cm, or in" unless match

      number = match[1].to_f
      raise JPMD::ValidationError, "#{path} must be positive" unless number.positive?

      number * PHYSICAL_UNIT_FACTORS.fetch(match[2])
    end

    def validate_positive_dimension(value, path)
      string = string_or_nil(value)
      match = string&.match(GENERIC_DIMENSION_PATTERN)
      raise JPMD::ValidationError, "#{path} must be a TeX dimension" unless match
      raise JPMD::ValidationError, "#{path} must be positive" unless match[1].to_f.positive?
    end

    def validate_non_negative_dimension(value, path)
      string = string_or_nil(value)
      match = string&.match(GENERIC_DIMENSION_PATTERN)
      raise JPMD::ValidationError, "#{path} must be a TeX dimension" unless match
      raise JPMD::ValidationError, "#{path} must be nonnegative" if match[1].to_f.negative?
    end

    def parse_positive_integer(value, path, minimum:)
      parsed =
        case value
        when Integer
          value
        when String
          Integer(value, exception: false)
        end

      raise JPMD::ValidationError, "#{path} must be an integer" unless parsed
      raise JPMD::ValidationError, "#{path} must be at least #{minimum}" unless parsed >= minimum

      parsed
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

    def fetch_hash(hash, key)
      value = fetch_required(hash, key)
      raise JPMD::ValidationError, "#{key} must be a map" unless value.is_a?(Hash)

      value
    end

    def fetch_required(hash, key)
      raise JPMD::ValidationError, "Missing required key: #{key}" unless hash.key?(key)

      hash[key]
    end

    def hash_at(hash, *keys)
      keys.reduce(hash) do |memo, key|
        return nil unless memo.is_a?(Hash)

        memo[key]
      end
    end

    def string_or_nil(value)
      value.nil? ? nil : value.to_s
    end

    def project_root
      base = File.file?(@config_path) ? File.dirname(@config_path) : File.dirname(@input_path)
      File.expand_path(base)
    end
  end
end
