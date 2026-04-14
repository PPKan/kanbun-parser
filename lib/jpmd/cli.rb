# frozen_string_literal: true

require "optparse"

module JPMD
  class CLI
    BUILD_PAIR_RETIREMENT_MESSAGE = <<~TEXT.freeze
      `build-pair` has been retired.
      Move `bibliography:` and optional `csl:` into the Markdown frontmatter, then run `jpmd build INPUT.md`.
    TEXT

    def self.start(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      command = @argv.shift

      case command
      when nil, "-h", "--help"
        puts root_usage
        0
      when "build"
        build_command
      when "build-pair"
        raise JPMD::ValidationError, BUILD_PAIR_RETIREMENT_MESSAGE.chomp
      else
        warn "Unknown command: #{command}"
        warn root_usage
        1
      end
    rescue JPMD::Error => e
      warn e.message
      1
    end

    private

    def build_command
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: jpmd build INPUT.md"

        opts.on("-h", "--help", "Show this help") do
          puts opts
          return 0
        end
      end

      remaining = parser.parse(@argv)
      input_path = remaining.first

      raise JPMD::ValidationError, parser.to_s unless input_path && remaining.length == 1

      compiler = JPMD::Compiler.new(
        input_path: File.expand_path(input_path, Dir.pwd),
        config_path: default_config_path
      )

      pdf_path = compiler.build
      puts "Wrote #{pdf_path}"
      0
    end

    def default_config_path
      File.expand_path("jpmd.yml", Dir.pwd)
    end

    def root_usage
      <<~TEXT
        Usage:
          jpmd build INPUT.md
      TEXT
    end
  end
end
