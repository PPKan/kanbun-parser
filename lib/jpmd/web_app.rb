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

      def state_value(*keys)
        keys.reduce(@state) do |memo, key|
          break nil unless memo.is_a?(Hash)

          memo[key]
        end
      end

      def source_mode?(value)
        state_value("source_mode") == value
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
      source = JPMD::WebForm.extract_source!(params)
      overrides = JPMD::WebForm.sanitize_overrides(@state.fetch("overrides"))
      result = current_build_runner.call(
        source_text: source.fetch("content"),
        source_name: source.fetch("filename"),
        overrides: overrides
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
