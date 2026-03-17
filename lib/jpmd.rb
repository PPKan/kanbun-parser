# frozen_string_literal: true

module JPMD
  Error = Class.new(StandardError)
  ValidationError = Class.new(Error)
  CommandError = Class.new(Error)
  APP_ROOT = File.expand_path("..", __dir__)
  CONFIG_ROOT = File.join(APP_ROOT, "config")
  BUNDLED_CONFIG_PATH = File.join(CONFIG_ROOT, "jpmd.yml")
  FILTER_PATH = File.join(CONFIG_ROOT, "pandoc", "filter.lua")
  TEMPLATE_PATH = File.join(CONFIG_ROOT, "tex", "template.tex")
  PREAMBLE_TEMPLATE_PATH = File.join(CONFIG_ROOT, "tex", "preamble.tex.erb")
end

require_relative "jpmd/config"
require_relative "jpmd/compiler"
require_relative "jpmd/cli"
