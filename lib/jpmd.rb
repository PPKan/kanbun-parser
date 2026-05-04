# frozen_string_literal: true

require "date"

module JPMD
  Error = Class.new(StandardError)
  ValidationError = Class.new(Error)
  CommandError = Class.new(Error)

  YAML_PERMITTED_CLASSES = [Date, Time].freeze

  def self.safe_yaml_load(content, aliases: true)
    YAML.safe_load(content, permitted_classes: YAML_PERMITTED_CLASSES, aliases: aliases) || {}
  end
end

require_relative "jpmd/document_metadata"
require_relative "jpmd/config"
require_relative "jpmd/compiler"
require_relative "jpmd/cli"
