# frozen_string_literal: true

require "optparse"

module JPMD
  class CLI
    BUILD_PAIR_RETIREMENT_MESSAGE = <<~TEXT.freeze
      `build-pair` has been retired.
      Use `jpmd build INPUT.md --bibliography refs.json`, or move `bibliography:` and optional `csl:` into the Markdown frontmatter.
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
      options = {
        bibliography: []
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: jpmd build INPUT.md [options]"

        opts.on("-o", "--output PDF", "Write PDF to this path") do |path|
          options[:output_path] = expand_cli_path(path)
        end

        opts.on("--tex TEX", "Also write intermediate TeX to this path") do |path|
          options[:tex_path] = expand_cli_path(path)
        end

        opts.on("-b", "--bibliography JSON", "Use bibliography file; may be repeated") do |path|
          options[:bibliography] << expand_cli_path(path)
        end

        opts.on("--csl CSL", "Use CSL style file") do |path|
          options[:csl] = expand_cli_path(path)
        end

        opts.on("--preset NAME", "Use layout preset") do |name|
          options[:preset] = name
        end

        opts.on("--suppress-bibliography", "Do not render bibliography at the end") do
          options[:suppress_bibliography] = true
        end

        opts.on("--render-bibliography", "Render bibliography at the end") do
          options[:suppress_bibliography] = false
        end

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
        output_path: options[:output_path],
        config_path: default_config_path,
        preset_name: options[:preset],
        emit_tex_path: options[:tex_path],
        metadata_overrides: metadata_overrides(options)
      )

      pdf_path = compiler.build
      puts "Wrote #{pdf_path}"
      0
    end

    def default_config_path
      File.expand_path("jpmd.yml", Dir.pwd)
    end

    def expand_cli_path(path)
      File.expand_path(path, Dir.pwd)
    end

    def metadata_overrides(options)
      overrides = {}
      overrides["bibliography"] = options.fetch(:bibliography) unless options.fetch(:bibliography).empty?
      overrides["csl"] = options.fetch(:csl) if options[:csl]
      overrides["suppress-bibliography"] = options.fetch(:suppress_bibliography) if options.key?(:suppress_bibliography)
      overrides
    end

    def root_usage
      <<~TEXT
        Usage:
          jpmd build INPUT.md [options]

        Build options:
          -o, --output PDF             Write PDF to this path
              --tex TEX                Also write intermediate TeX to this path
          -b, --bibliography JSON      Use bibliography file; may be repeated
              --csl CSL                Use CSL style file
              --preset NAME            Use layout preset
              --suppress-bibliography  Do not render bibliography at the end
              --render-bibliography    Render bibliography at the end
          -h, --help                   Show command help
      TEXT
    end
  end
end
