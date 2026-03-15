# frozen_string_literal: true

module JPMD
  Error = Class.new(StandardError)
  ValidationError = Class.new(Error)
  CommandError = Class.new(Error)
end

require_relative "jpmd/config"
require_relative "jpmd/compiler"
require_relative "jpmd/cli"
