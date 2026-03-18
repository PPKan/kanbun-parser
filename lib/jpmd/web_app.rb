# frozen_string_literal: true

require "erb"
require "sinatra/base"

module JPMD
  class WebApp < Sinatra::Base
    set :repo_root, File.expand_path("../..", __dir__)
    set :views, File.join(settings.repo_root, "views")
    set :protection, false
    set :method_override, false
    set :show_exceptions, false
    set :raise_errors, false
    set :build_runner, nil

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end

      def source_samples
        JPMD::WebForm.source_samples
      end

      def bibliography_samples
        JPMD::WebForm.bibliography_samples
      end

      def csl_samples
        JPMD::WebForm.csl_samples
      end

      def selected_source_sample
        JPMD::WebForm.selected_source_sample(state_value("source_sample"))
      end

      def selected_bibliography_sample
        JPMD::WebForm.selected_bibliography_sample(state_value("bibliography_sample"))
      end

      def selected_csl_sample
        JPMD::WebForm.selected_csl_sample(state_value("csl_sample"))
      end

      def sample_file_content(relative_path)
        @sample_file_contents ||= {}
        @sample_file_contents[relative_path] ||= begin
          path = File.join(settings.repo_root, relative_path)
          File.read(path, mode: "r:utf-8")
        rescue Errno::ENOENT
          "Missing bundled sample: #{relative_path}"
        end
      end

      def state_value(*keys)
        keys.reduce(@state) do |memo, key|
          break nil unless memo.is_a?(Hash)

          memo[key]
        end
      end

      def source_mode?(value)
        state_value("source_mode") == value
      end

      def bibliography_mode?(value)
        state_value("bibliography_mode") == value
      end

      def csl_mode?(value)
        state_value("csl_mode") == value
      end

      def advanced_open?
        return true if @error_message

        current = state_value("overrides", "kanbun")
        defaults = JPMD::WebForm.default_state(repo_root: settings.repo_root).dig("overrides", "kanbun")
        current != defaults
      end

      def current_build_runner
        configured = settings.build_runner
        configured = configured[:callable] if configured.is_a?(Hash)
        configured || JPMD::WebBuilder.new(repo_root: settings.repo_root).method(:build)
      end
    end

    get "/" do
      @error_message = nil
      @state = JPMD::WebForm.default_state(repo_root: settings.repo_root)
      erb :index
    end

    post "/build" do
      @state = JPMD::WebForm.state_from_params(repo_root: settings.repo_root, params: params)
      source = JPMD::WebForm.extract_source!(repo_root: settings.repo_root, params: params)
      bibliography = JPMD::WebForm.resolve_bibliography!(params: params)
      csl = JPMD::WebForm.resolve_csl!(params: params)
      overrides = JPMD::WebForm.sanitize_overrides(@state.fetch("overrides"))
      result = current_build_runner.call(
        source_text: source.fetch("content"),
        source_name: source.fetch("filename"),
        overrides: overrides,
        bibliography: bibliography,
        csl: csl
      )

      content_type "application/pdf"
      attachment result.fetch("download_name")
      result.fetch("pdf_data")
    rescue JPMD::Error => e
      @error_message = e.message
      status 422
      erb :index
    end
  end
end
