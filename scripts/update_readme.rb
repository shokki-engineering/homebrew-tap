#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "ripper"

# Parse metadata without evaluating formulae or loading Homebrew.
class ReadmeUpdater
  TAP = "shokki-engineering/tap"
  SECTIONS = { "FORMULA" => "Formula", "CASK" => "Casks" }.freeze

  def initialize(root)
    @root = Pathname.new(root)
  end

  def update(check: false)
    path = @root.join("README.md")
    original = path.read
    updated = original.dup
    SECTIONS.each do |label, directory|
      first = "<!-- BEGIN GENERATED #{label} LIST -->"
      last = "<!-- END GENERATED #{label} LIST -->"
      if updated.scan(first).length != 1 || updated.scan(last).length != 1 ||
         updated.index(first) >= updated.index(last)
        raise ArgumentError, "README must contain exactly one ordered pair of #{label} list markers"
      end

      pattern = /#{Regexp.escape(first)}.*?#{Regexp.escape(last)}/m
      updated.sub!(pattern) { "#{first}\n\n#{table(directory, cask: label == "CASK")}\n\n#{last}" }
    end
    return updated == original if check

    path.write(updated) if updated != original
    true
  end

  private

  def table(directory, cask:)
    paths = @root.glob("#{directory}/**/*.rb").sort_by { |path| [path.basename.to_s, path.to_s] }
    return "_None available yet._" if paths.empty?

    names = paths.map { |path| path.basename(".rb").to_s }
    raise ArgumentError, "Duplicate package names in #{directory}" if names.uniq != names

    rows = paths.zip(names).map do |path, name|
      unless name.match?(/\A[a-z0-9][a-z0-9+_.@-]*\z/)
        raise ArgumentError, "Invalid package filename: #{path}"
      end

      command = "brew install #{"--cask " if cask}#{TAP}/#{name}"
      "| `#{name}` | #{escape_markdown(description(path))} | `#{command}` |"
    end
    (["| #{cask ? "Cask" : "Formula"} | Description | Install |", "| --- | --- | --- |"] + rows).join("\n")
  end

  def description(path)
    source = path.read
    raise ArgumentError, "Invalid Ruby syntax: #{path}" unless Ripper.sexp(source)

    # Only accept a complete, literal desc declaration. Interpolation and
    # computed descriptions would require executing untrusted package code.
    source.each_line do |line|
      match = line.match(/^\s*desc\s+("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')\s*(?:#.*)?$/)
      next unless match

      literal = match[1]
      tokens = Ripper.lex(literal)
      next if tokens.any? { |token| token[1] == :on_embexpr_beg || token[1] == :on_embvar }

      value = if literal.start_with?('"')
        # String#undump accepts ASCII source only; encode Unicode first.
        literal.gsub(/[^\x00-\x7F]/) { |char| "\\u{#{char.ord.to_s(16)}}" }.undump
      else
        literal[1...-1].gsub(/\\(['\\])/, '\1')
      end
      return value unless value.strip.empty?
    end
    raise ArgumentError, "Missing static, non-empty desc string: #{path}"
  end

  def escape_markdown(value)
    value.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
         .gsub("\\", "&#92;").gsub("|", "&#124;").gsub("`", "&#96;")
         .gsub("*", "&#42;").gsub("_", "&#95;").gsub(/\s+/, " ").strip
  end
end

if $PROGRAM_NAME == __FILE__
  unless [[], ["--check"], ["--help"]].include?(ARGV)
    warn "Usage: ruby scripts/update_readme.rb [--check | --help]"
    exit 2
  end
  if ARGV == ["--help"]
    puts "Usage: ruby scripts/update_readme.rb [--check | --help]"
    exit
  end

  begin
    synced = ReadmeUpdater.new(File.expand_path("..", __dir__)).update(check: ARGV == ["--check"])
    warn "README package lists are out of date. Run ruby scripts/update_readme.rb." unless synced
    exit(synced ? 0 : 1)
  rescue ArgumentError, SystemCallError => e
    warn e.message
    exit 1
  end
end
