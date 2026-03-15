# frozen_string_literal: true

require_relative "test_helper"

class JPMDConfigTest < Minitest::Test
  include JPMDTestHelper

  def test_default_preset_derives_expected_grid
    with_temp_markdown do |input_path, config_path|
      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: nil
      ).resolve

      derived = resolved.fetch("derived")
      assert_equal 30, derived.fetch("characters_per_line")
      assert_equal 30, derived.fetch("lines_per_page")
      assert_equal "12pt", derived.fetch("body_size")
      assert_operator derived.fetch("kanjiskip_pt"), :>, 0
      assert_operator derived.fetch("baselineskip_pt"), :>, 0
    end
  end

  def test_document_overrides_change_layout
    frontmatter = {
      "layout" => {
        "grid" => {
          "characters_per_line" => 20,
          "lines_per_page" => 24
        },
        "font" => {
          "body_size" => "10pt"
        }
      }
    }

    with_temp_markdown(frontmatter) do |input_path, config_path|
      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: nil
      ).resolve

      derived = resolved.fetch("derived")
      assert_equal 20, derived.fetch("characters_per_line")
      assert_equal 24, derived.fetch("lines_per_page")
      assert_equal "10pt", derived.fetch("body_size")
    end
  end

  def test_invalid_negative_shift_is_rejected
    frontmatter = {
      "kanbun" => {
        "furigana" => {
          "shift" => {
            "left" => "-1pt"
          }
        }
      }
    }

    with_temp_markdown(frontmatter) do |input_path, config_path|
      error = assert_raises(JPMD::ValidationError) do
        JPMD::Config.new(
          input_path: input_path,
          config_path: config_path,
          cli_preset: nil
        ).resolve
      end

      assert_match(/kanbun\.furigana\.shift\.left/, error.message)
    end
  end

  def test_impossible_character_count_is_rejected
    frontmatter = {
      "layout" => {
        "grid" => {
          "characters_per_line" => 40
        }
      }
    }

    with_temp_markdown(frontmatter) do |input_path, config_path|
      error = assert_raises(JPMD::ValidationError) do
        JPMD::Config.new(
          input_path: input_path,
          config_path: config_path,
          cli_preset: nil
        ).resolve
      end

      assert_match(/negative kanjiskip/, error.message)
    end
  end

  def test_project_preset_overrides_builtin_defaults
    with_temp_markdown do |input_path, config_path|
      File.write(config_path, <<~YAML, mode: "w:utf-8")
        default_preset: academic
        presets:
          academic:
            layout:
              font:
                body_size: 11pt
      YAML

      resolved = JPMD::Config.new(
        input_path: input_path,
        config_path: config_path,
        cli_preset: nil
      ).resolve

      assert_equal "11pt", resolved.fetch("derived").fetch("body_size")
    end
  end
end
