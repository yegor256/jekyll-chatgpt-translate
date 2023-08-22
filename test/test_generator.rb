# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2023 Yegor Bugayenko
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'tmpdir'
require 'webmock/minitest'
require_relative '../lib/jekyll-chatgpt-translate/generator'

# Generator test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::GeneratorTest < Minitest::Test
  class FakeSite
    attr_reader :config, :pages

    def initialize(config, docs)
      @config = config
      @docs = docs
      @pages = []
    end

    def posts
      FakePosts.new(@docs)
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
      File.dirname(@docs[0])
    end

    def in_theme_dir(base, _foo = nil, _bar = nil)
      base
    end

    def in_dest_dir(*paths)
      paths[0].dup
    end
  end

  class FakeDocument
    def initialize(path)
      @path = path
    end

    def content
      'Hello, world!'
    end

    def data
      {}
    end

    def []=(key, value); end

    def [](key)
      if key == 'date'
        Time.now
      elsif key == 'title'
        'Hello!'
      else
        ''
      end
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

  class FakePosts
    attr_reader :config

    def initialize(docs)
      @docs = docs
    end

    def docs
      @docs.map { |d| FakeDocument.new(d) }
    end
  end

  def test_simple_scenario
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\n---\n\nHello, world!")
      site = FakeSite.new(
        {
          'url' => 'https://www.yegor256.com/',
          'chatgpt-translate' => {
            'targets' => [
              {
                'language' => 'zh',
                'layout' => 'chinese',
                'permalink' => ':slug.html'
              }
            ]
          }
        },
        [post]
      )
      gen = GptTranslate::Generator.new
      stub_request(:get, 'https://www.yegor256.com/.html').to_return(body: '')
      gen.generate(site)
      assert_equal(1, site.pages.count)
    end
  end

  def test_threshold_stops
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\n---\n\nHello, world!")
      site = FakeSite.new(
        {
          'chatgpt-translate' => {
            'threshold' => 1,
            'targets' => [
              {
                'language' => 'zh',
                'permalink' => ':slug.html'
              },
              {
                'language' => 'fr',
                'permalink' => ':year/:slug.html'
              }
            ]
          }
        },
        [post, post]
      )
      gen = GptTranslate::Generator.new
      stub_request(:get, 'https://www.yegor256.com/.html').to_return(body: '')
      gen.generate(site)
      assert_equal(1, site.pages.count)
    end
  end
end
