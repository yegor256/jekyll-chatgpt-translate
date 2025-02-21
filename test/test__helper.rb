# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

$stdout.sync = true

require 'simplecov'
SimpleCov.start

require 'jekyll'
Jekyll.logger.adjust_verbosity(verbose: true)

# The module we are in.
module GptTranslate; end

# Fake.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::FakeSite
  attr_reader :config, :pages, :static_files

  def initialize(config, docs = [])
    @config = config
    @docs = docs
    @pages = []
    @static_files = []
  end

  def posts
    GptTranslate::FakePosts.new(@docs)
  end

  def permalink_style
    ''
  end

  def frontmatter_defaults
    Jekyll::FrontmatterDefaults.new(self)
  end

  def converters
    [Jekyll::Converters::Markdown.new({ 'markdown_ext' => 'md' })]
  end

  def source
    ''
  end

  def dest
    return '' if @docs.empty?
    File.dirname(@docs[0])
  end

  def in_theme_dir(base, _foo = nil, _bar = nil)
    base
  end

  def in_dest_dir(*paths)
    paths[0].dup
  end
end

# Fake.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::FakeDocument
  attr_reader :data

  def initialize(path)
    @path = path
    @data = { 'date' => Time.now, 'title' => 'Hello!' }
  end

  def content
    'Hello, world!'
  end

  def []=(key, value)
    @data[key] = value
  end

  def [](key)
    @data[key] || ''
  end

  def relative_path
    @path
  end

  def url
    '2023-01-01-hello.html'
  end

  def basename
    '2023-01-01-hello.md'
  end
end

# Fake.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::FakePosts
  attr_reader :config

  def initialize(docs)
    @docs = docs
  end

  def docs
    @docs.map { |d| GptTranslate::FakeDocument.new(d) }
  end
end
