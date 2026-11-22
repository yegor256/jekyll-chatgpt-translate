# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'tmpdir'
require 'webmock/minitest'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/generator'

# Generator test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
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

  def test_configured_layout_is_not_overwritten_by_post_layout
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\nlayout: post\n---\n\nHello, world!")
      site = GptTranslate::FakeSite.new(
        {
          'chatgpt-translate' => {
            'tmpdir' => home,
            'layout' => 'translated',
            'targets' => [
              {
                'language' => 'fr',
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
      front = File.read(File.join(home, 'fr', '2023-01-01-hello-fr.md'))
      assert_includes(front, 'layout: translated', "Front matter: #{front}")
      refute_includes(front, 'layout: post', "Front matter: #{front}")
    end
  end

  def test_target_layout_wins_over_configured_one
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\nlayout: post\n---\n\nHello, world!")
      site = GptTranslate::FakeSite.new(
        {
          'chatgpt-translate' => {
            'tmpdir' => home,
            'layout' => 'translated',
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
      front = File.read(File.join(home, 'zh', '2023-01-01-hello-zh.md'))
      assert_includes(front, 'layout: chinese', "Front matter: #{front}")
    end
  end

  def test_default_layout_when_not_configured
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\nlayout: post\n---\n\nHello, world!")
      site = GptTranslate::FakeSite.new(
        {
          'chatgpt-translate' => {
            'tmpdir' => home,
            'targets' => [
              {
                'language' => 'fr',
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
      front = File.read(File.join(home, 'fr', '2023-01-01-hello-fr.md'))
      assert_includes(front, 'layout: translated', "Front matter: #{front}")
    end
  end

  def test_only_filter_uses_post_layout
    Dir.mktmpdir do |home|
      post = File.join(home, '2023-01-01-hello.md')
      File.write(post, "---\ntitle: Hello\nlayout: post\n---\n\nHello, world!")
      site = GptTranslate::FakeSite.new(
        {
          'chatgpt-translate' => {
            'tmpdir' => home,
            'targets' => [
              {
                'language' => 'fr',
                'only' => 'post',
                'permalink' => ':slug.html'
              },
              {
                'language' => 'de',
                'only' => 'page',
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
      assert_path_exists(File.join(home, 'fr', '2023-01-01-hello-fr.md'))
      refute_path_exists(File.join(home, 'de', '2023-01-01-hello-de.md'))
    end
  end
end
