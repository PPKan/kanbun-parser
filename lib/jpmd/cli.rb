# frozen_string_literal: true

require "optparse"

module JPMD
  class CLI
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
      when "serve"
        serve_command
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
      options = {
        config_path: File.expand_path("jpmd.yml", Dir.pwd)
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: jpmd build INPUT.md -o OUTPUT.pdf [options]"

        opts.on("-o", "--output PATH", "Write PDF to PATH") do |value|
          options[:output_path] = File.expand_path(value, Dir.pwd)
        end

        opts.on("--config PATH", "Read project config from PATH") do |value|
          options[:config_path] = File.expand_path(value, Dir.pwd)
        end

        opts.on("--preset NAME", "Use preset NAME as the base preset") do |value|
          options[:preset_name] = value
        end

        opts.on("--emit-tex PATH", "Also write rendered TeX to PATH") do |value|
          options[:emit_tex_path] = File.expand_path(value, Dir.pwd)
        end

        opts.on("-h", "--help", "Show this help") do
          puts opts
          return 0
        end
      end

      remaining = parser.parse(@argv)
      input_path = remaining.first

      raise JPMD::ValidationError, parser.to_s unless input_path
      raise JPMD::ValidationError, "Missing required -o/--output PATH" unless options[:output_path]

      compiler = JPMD::Compiler.new(
        input_path: File.expand_path(input_path, Dir.pwd),
        output_path: options[:output_path],
        config_path: options[:config_path],
        preset_name: options[:preset_name],
        emit_tex_path: options[:emit_tex_path]
      )

      pdf_path = compiler.build
      puts "Wrote #{pdf_path}"
      0
    end

    def serve_command
      options = {
        host: "127.0.0.1",
        port: 4567
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: jpmd serve [options]"

        opts.on("--host HOST", "Bind the local web app to HOST") do |value|
          options[:host] = value.to_s
        end

        opts.on("--port PORT", Integer, "Bind the local web app to PORT") do |value|
          options[:port] = value
        end

        opts.on("-h", "--help", "Show this help") do
          puts opts
          return 0
        end
      end

      parser.parse!(@argv)

      raise JPMD::ValidationError, parser.to_s unless @argv.empty?
      raise JPMD::ValidationError, "--host must not be empty" if options[:host].strip.empty?
      raise JPMD::ValidationError, "--port must be between 1 and 65535" unless (1..65_535).cover?(options[:port])

      begin
        require_relative "web_form"
        require_relative "web_builder"
        require_relative "web_app"
      rescue LoadError => e
        raise JPMD::CommandError, "Missing web dependency: #{e.message}. Run bundle install before jpmd serve."
      end

      puts "Listening on http://#{options[:host]}:#{options[:port]}"

      JPMD::WebApp.set :repo_root, JPMD::Compiler::APP_ROOT
      JPMD::WebApp.set :build_runner, { callable: JPMD::WebBuilder.new(repo_root: JPMD::Compiler::APP_ROOT).method(:build) }
      JPMD::WebApp.run!(bind: options[:host], port: options[:port])
      0
    end

    def root_usage
      <<~TEXT
        Usage:
          jpmd build INPUT.md -o OUTPUT.pdf [--config jpmd.yml] [--preset academic] [--emit-tex out.tex]
          jpmd serve [--host 127.0.0.1] [--port 4567]
      TEXT
    end
  end
end
