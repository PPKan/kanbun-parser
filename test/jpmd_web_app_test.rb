# frozen_string_literal: true

require "rack/test"
require "tempfile"
require_relative "test_helper"
require_relative "../lib/jpmd/web_form"
require_relative "../lib/jpmd/web_builder"
require_relative "../lib/jpmd/web_app"

class JPMDWebAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    JPMD::WebApp
  end

  def setup
    @captured = []
    @previous_repo_root = app.settings.repo_root
    @previous_build_runner = app.settings.build_runner
    app.set :repo_root, File.expand_path("..", __dir__)
    header "Host", "localhost"
    app.set :build_runner, {
      callable: lambda { |**kwargs|
        @captured << kwargs
        {
          "pdf_data" => "%PDF-web-test",
          "download_name" => "document.pdf"
        }
      }
    }
  end

  def teardown
    app.set :repo_root, @previous_repo_root
    app.set :build_runner, @previous_build_runner
  end

  def test_get_root_renders_form_sections
    get "/"

    assert last_response.ok?
    assert_includes last_response.body, "Bundled Sample"
    assert_includes last_response.body, "Paste Markdown"
    assert_includes last_response.body, "Upload Markdown File"
    assert_includes last_response.body, "Citation Assets"
    assert_includes last_response.body, "Upload Bibliography"
    assert_includes last_response.body, "Upload CSL"
    assert_includes last_response.body, "Page Controls"
    assert_includes last_response.body, "Advanced Kanbun Controls"
  end

  def test_bundled_sample_build_returns_pdf
    post "/build", {
      "source_mode" => "sample",
      "source_sample" => "minimal-kanbun",
      "bibliography_mode" => "sample",
      "bibliography_sample" => "zotero-json",
      "csl_mode" => "sample",
      "csl_sample" => "chicago-notes"
    }

    assert last_response.ok?
    assert_equal "application/pdf", last_response.media_type
    assert_equal "minimal-kanbun.pdf", @captured.last.fetch(:source_name).sub(/\.md\z/, ".pdf")
    assert_includes @captured.last.fetch(:source_text), "漢文最小例"
    assert_equal "references/zotero-export.json", @captured.last.dig(:bibliography, "workspace_path")
    assert_equal "references/chicago-notes-bibliography.csl", @captured.last.dig(:csl, "workspace_path")
  end

  def test_pasted_markdown_build_returns_pdf
    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Heading\n\n本文",
      "overrides" => {
        "layout" => {
          "grid" => {
            "characters_per_line" => "31"
          }
        }
      }
    }

    assert last_response.ok?
    assert_equal "application/pdf", last_response.media_type
    assert_includes last_response["Content-Disposition"], "document.pdf"
    assert_equal "%PDF-web-test", last_response.body
    assert_equal "# Heading\n\n本文", @captured.last.fetch(:source_text)
    assert_equal "31", @captured.last.dig(:overrides, "layout", "grid", "characters_per_line")
    assert_equal "references/zotero-export.json", @captured.last.dig(:bibliography, "workspace_path")
    assert_equal "references/chicago-notes-bibliography.csl", @captured.last.dig(:csl, "workspace_path")
  end

  def test_uploaded_markdown_build_returns_pdf
    upload = uploaded_file("sample.md", "# Uploaded\n\n本文", "text/markdown")

    post "/build", {
      "source_mode" => "upload",
      "markdown_text" => "ignored",
      "markdown_file" => upload
    }

    assert last_response.ok?
    assert_equal "application/pdf", last_response.media_type
    assert_equal "# Uploaded\n\n本文", @captured.last.fetch(:source_text)
    assert_equal "sample.md", @captured.last.fetch(:source_name)
  end

  def test_uploaded_bibliography_and_csl_are_passed_to_builder
    bibliography = uploaded_file("custom-library.json", "[{\"id\":\"demo\"}]", "application/json")
    csl = uploaded_file("custom-style.csl", "<style></style>", "application/xml")

    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Pasted\n\n本文",
      "bibliography_mode" => "upload",
      "bibliography_file" => bibliography,
      "csl_mode" => "upload",
      "csl_file" => csl
    }

    assert last_response.ok?
    assert_equal "upload", @captured.last.dig(:bibliography, "mode")
    assert_equal "bibliography", @captured.last.dig(:bibliography, "kind")
    assert_equal "custom-library.json", @captured.last.dig(:bibliography, "filename")
    assert_equal "upload", @captured.last.dig(:csl, "mode")
    assert_equal "csl", @captured.last.dig(:csl, "kind")
    assert_equal "custom-style.csl", @captured.last.dig(:csl, "filename")
  end

  def test_source_mode_controls_which_input_is_compiled
    upload = uploaded_file("sample.md", "# Uploaded\n\n本文", "text/markdown")

    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Pasted\n\n本文",
      "markdown_file" => upload
    }

    assert last_response.ok?
    assert_equal "# Pasted\n\n本文", @captured.last.fetch(:source_text)
  end

  def test_invalid_upload_type_is_rejected
    upload = uploaded_file("sample.png", "not markdown", "image/png")

    post "/build", {
      "source_mode" => "upload",
      "markdown_file" => upload
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Uploaded file must end in .md or .markdown."
  end

  def test_empty_upload_is_rejected
    upload = uploaded_file("sample.md", "   \n", "text/plain")

    post "/build", {
      "source_mode" => "upload",
      "markdown_file" => upload
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Uploaded file is empty."
  end

  def test_invalid_bibliography_upload_type_is_rejected
    upload = uploaded_file("sample.csv", "id,title", "text/csv")

    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Pasted\n\n本文",
      "bibliography_mode" => "upload",
      "bibliography_file" => upload
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Bibliography upload must end in .json or .bib."
  end

  def test_invalid_csl_upload_type_is_rejected
    upload = uploaded_file("sample.txt", "not csl", "text/plain")

    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Pasted\n\n本文",
      "csl_mode" => "upload",
      "csl_file" => upload
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "CSL upload must end in .csl."
  end

  def test_compile_failures_render_friendly_error
    app.set :build_runner, {
      callable: lambda { |**_kwargs|
        raise JPMD::CommandError, "LuaLaTeX failed:\nmissing package"
      }
    }

    post "/build", {
      "source_mode" => "paste",
      "markdown_text" => "# Broken"
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Build failed"
    assert_includes last_response.body, "LuaLaTeX failed"
  end

  private

  def uploaded_file(filename, content, content_type)
    tempfile = Tempfile.new(["jpmd-web", File.extname(filename)])
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, content_type, original_filename: filename)
  end
end
