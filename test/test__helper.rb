# frozen_string_literal: true

# Copyright (c) 2023-2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
