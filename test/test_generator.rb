# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'tmpdir'
require 'webmock/minitest'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/generator'

# Generator test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::GeneratorTest < Minitest::Test
  def test_simple_scenario
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\n---\n\nHello, world!")
      site = GptTranslate::FakeSite.new(
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
      site = GptTranslate::FakeSite.new(
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
