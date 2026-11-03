# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require_relative "../scripts/update_readme"

# Exercise tap updates and CLI failures in isolated repository fixtures.
class ReadmeUpdaterTest < Minitest::Test
  TEMPLATE = <<~MARKDOWN
    # Example tap

    Hand-written installation and release instructions.

    <!-- BEGIN GENERATED FORMULA LIST -->
    old formula list
    <!-- END GENERATED FORMULA LIST -->

    <!-- BEGIN GENERATED CASK LIST -->
    old cask list
    <!-- END GENERATED CASK LIST -->

    Keep this footer.
  MARKDOWN

  def setup
    @root = Pathname.new(Dir.mktmpdir("tap-readme-test"))
    @root.join("README.md").write(TEMPLATE)
    @updater = ReadmeUpdater.new(@root)
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def package(relative, source)
    path = @root.join(relative)
    path.dirname.mkpath
    path.write(source)
  end

  def readme
    @root.join("README.md").read
  end

  def test_empty_tap_and_preserved_prose
    @updater.update
    assert_equal 2, readme.scan("_None available yet._").length
    assert_includes readme, "Hand-written installation and release instructions."
    assert readme.end_with?("Keep this footer.\n")
  end

  def test_sorted_recursive_formulae_and_cask_install_commands
    package("Formula/z/zeta.rb", "class Zeta < Formula\n  desc \"Zeta tool\"\nend\n")
    package("Formula/alpha@2.rb", "desc 'Alpha tool' # comment\n")
    package("Casks/viewer.rb", 'desc "Viewer app"')
    @updater.update
    assert_operator readme.index("`alpha@2`"), :<, readme.index("`zeta`")
    assert_includes readme, "`brew install shokki-engineering/tap/alpha@2`"
    assert_includes readme, "`brew install --cask shokki-engineering/tap/viewer`"
  end

  def test_check_detects_drift_without_writing_and_update_is_idempotent
    refute @updater.update(check: true)
    assert_equal TEMPLATE, readme
    @updater.update
    once = readme
    assert @updater.update(check: true)
    @updater.update
    assert_equal once, readme
    package("Formula/new.rb", 'desc "New package"')
    refute @updater.update(check: true)
    assert_equal once, readme
  end

  def test_removed_packages_disappear
    package("Formula/old.rb", 'desc "Old tool"')
    @updater.update
    @root.join("Formula/old.rb").delete
    @updater.update
    refute_includes readme, "`old`"
    assert_equal 2, readme.scan("_None available yet._").length
  end

  def test_markdown_and_ruby_string_escapes
    package("Formula/example.rb", %q(desc "A \"quote\" | `code` <tag> & *star*_end_"))
    @updater.update
    assert_includes readme, 'A "quote" &#124; &#96;code&#96; &lt;tag&gt; &amp; &#42;star&#42;&#95;end&#95;'
    package("Casks/example.rb", %q(desc 'User\'s \\ path'))
    @updater.update
    assert_includes readme, "User's &#92; path"
  end

  def test_definition_is_never_executed
    package("Formula/safe.rb", "raise 'must not execute'\ndesc \"Safe tool\"\n")
    @updater.update
    assert_includes readme, "Safe tool"
  end

  def test_unicode_descriptions
    package("Formula/cafe.rb", 'desc "Café ☕"')
    package("Casks/cafe.rb", "desc 'Café ☕'")
    @updater.update
    assert_equal 2, readme.scan("Café ☕").length
  end

  def test_dynamic_missing_and_empty_descriptions_are_rejected
    ['desc "#{dangerous_call}"', 'desc "#@value"', 'desc "   "', 'homepage "https://example.com"',
     "desc compute_description"].each do |source|
      package("Formula/bad.rb", source)
      assert_raises(ArgumentError) { @updater.update }
      assert_equal TEMPLATE, readme
    end
  end

  def test_invalid_ruby_is_rejected_before_writing
    package("Formula/bad.rb", "class Broken\ndesc \"Broken\"\n")
    assert_match(/Invalid Ruby syntax/, assert_raises(ArgumentError) { @updater.update }.message)
    assert_equal TEMPLATE, readme
  end

  def test_duplicate_package_names_are_rejected
    package("Formula/a/tool.rb", 'desc "First"')
    package("Formula/b/tool.rb", 'desc "Second"')
    assert_match(/Duplicate/, assert_raises(ArgumentError) { @updater.update }.message)
  end

  def test_invalid_filenames_are_rejected
    package("Formula/bad name.rb", 'desc "Tool"')
    assert_match(/Invalid package filename/, assert_raises(ArgumentError) { @updater.update }.message)
  end

  def test_missing_duplicate_and_reversed_markers_are_rejected_without_writing
    first = "<!-- BEGIN GENERATED CASK LIST -->"
    last = "<!-- END GENERATED CASK LIST -->"
    reversed = TEMPLATE.gsub(/#{Regexp.escape(first)}|#{Regexp.escape(last)}/, first => last, last => first)
    [TEMPLATE.sub(first, ""), TEMPLATE + first, reversed].each do |source|
      @root.join("README.md").write(source)
      assert_raises(ArgumentError) { @updater.update }
      assert_equal source, readme
    end
  end

  def test_cli_exit_codes_and_location_independence
    package("scripts/update_readme.rb", File.read(File.expand_path("../scripts/update_readme.rb", __dir__)))
    script = @root.join("scripts/update_readme.rb").to_s
    _, error, status = Open3.capture3(RbConfig.ruby, script, "--check", chdir: "/")
    assert_equal 1, status.exitstatus
    assert_includes error, "out of date"
    assert Open3.capture3(RbConfig.ruby, script, chdir: "/").last.success?
    assert Open3.capture3(RbConfig.ruby, script, "--check").last.success?
    assert_equal 2, Open3.capture3(RbConfig.ruby, script, "--typo").last.exitstatus
    assert Open3.capture3(RbConfig.ruby, script, "--help").last.success?
  end
end
