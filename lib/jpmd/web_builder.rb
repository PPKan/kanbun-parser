# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "yaml"

module JPMD
  class WebBuilder
    def initialize(repo_root:, compiler_class: JPMD::Compiler)
      @repo_root = File.expand_path(repo_root)
      @compiler_class = compiler_class
    end

    def build(source_text:, source_name:, overrides:, bibliography: nil, csl: nil)
      Dir.mktmpdir("jpmd-web-") do |tmpdir|
        workspace = File.join(tmpdir, "workspace")
        FileUtils.mkdir_p(workspace)

        input_path = File.join(workspace, "document.md")
        output_path = File.join(workspace, "document.pdf")
        request_config_path = File.join(workspace, "request.jpmd.yml")
        pandoc_metadata_overrides = {}

        File.write(input_path, source_text, mode: "w:utf-8")
        File.write(request_config_path, YAML.dump(request_config_payload(overrides)), mode: "w:utf-8")
        copy_references(workspace)
        write_reference_asset(workspace, bibliography).tap do |path|
          pandoc_metadata_overrides["bibliography"] = path if path
        end
        write_reference_asset(workspace, csl).tap do |path|
          pandoc_metadata_overrides["csl"] = path if path
        end

        compiler = @compiler_class.new(
          input_path: input_path,
          output_path: output_path,
          config_path: File.join(@repo_root, "jpmd.yml"),
          preset_name: nil,
          emit_tex_path: nil,
          working_dir: workspace,
          asset_root: @repo_root,
          runtime_overrides: overrides,
          pandoc_metadata_overrides: pandoc_metadata_overrides
        )

        compiler.build

        {
          "pdf_data" => File.binread(output_path),
          "download_name" => download_name_for(source_name)
        }
      end
    end

    private

    def copy_references(workspace)
      source = File.join(@repo_root, "references")
      return unless Dir.exist?(source)

      FileUtils.cp_r(source, workspace)
    end

    def write_reference_asset(workspace, asset)
      return nil unless asset.is_a?(Hash)

      case asset.fetch("mode")
      when "sample"
        asset.fetch("workspace_path")
      when "upload"
        write_uploaded_asset(workspace, asset)
      else
        nil
      end
    end

    def write_uploaded_asset(workspace, asset)
      uploads_dir = File.join(workspace, "uploads")
      FileUtils.mkdir_p(uploads_dir)

      original_name = asset.fetch("filename").to_s
      extension = File.extname(original_name).downcase
      stem = File.basename(original_name, extension).gsub(/[^A-Za-z0-9._-]+/, "-").gsub(/\A-+|-+\z/, "")
      stem = default_upload_stem(asset) if stem.empty?

      filename = "#{stem}#{extension}"
      target = File.join(uploads_dir, filename)
      File.write(target, asset.fetch("content"), mode: "w:utf-8")
      File.join("uploads", filename)
    end

    def default_upload_stem(asset)
      asset.fetch("kind") == "csl" ? "style" : "bibliography"
    end

    def request_config_payload(overrides)
      {
        "default_preset" => default_preset_name,
        "presets" => {
          default_preset_name => overrides
        }
      }
    end

    def default_preset_name
      @default_preset_name ||= begin
        config_path = File.join(@repo_root, "jpmd.yml")
        if File.file?(config_path)
          config = YAML.safe_load(File.read(config_path, mode: "r:utf-8"), aliases: true) || {}
          config.fetch("default_preset", "academic")
        else
          "academic"
        end.to_s
      end
    end

    def download_name_for(source_name)
      stem = File.basename(source_name.to_s, File.extname(source_name.to_s))
      stem = stem.gsub(/[^A-Za-z0-9._-]+/, "-").gsub(/\A-+|-+\z/, "")
      stem = "document" if stem.empty?
      "#{stem}.pdf"
    end
  end
end
