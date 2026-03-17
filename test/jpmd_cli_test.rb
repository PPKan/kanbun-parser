# frozen_string_literal: true

require_relative "test_helper"

class JPMDCLITest < Minitest::Test
  def test_default_config_path_prefers_root_jpmd_yml
    Dir.mktmpdir("jpmd-cli-") do |dir|
      File.write(File.join(dir, "jpmd.yml"), "", mode: "w:utf-8")
      FileUtils.mkdir_p(File.join(dir, "config"))
      File.write(File.join(dir, "config", "jpmd.yml"), "", mode: "w:utf-8")

      cli = JPMD::CLI.new([])
      assert_equal File.join(dir, "jpmd.yml"), cli.send(:default_config_path, dir)
    end
  end

  def test_default_config_path_uses_config_subdirectory_when_present
    Dir.mktmpdir("jpmd-cli-") do |dir|
      FileUtils.mkdir_p(File.join(dir, "config"))
      File.write(File.join(dir, "config", "jpmd.yml"), "", mode: "w:utf-8")

      cli = JPMD::CLI.new([])
      assert_equal File.join(dir, "config", "jpmd.yml"), cli.send(:default_config_path, dir)
    end
  end

  def test_default_config_path_falls_back_to_bundled_config
    Dir.mktmpdir("jpmd-cli-") do |dir|
      cli = JPMD::CLI.new([])
      assert_equal JPMD::BUNDLED_CONFIG_PATH, cli.send(:default_config_path, dir)
    end
  end
end
