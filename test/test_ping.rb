# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'webmock/minitest'
require 'jekyll'
require 'tempfile'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/ping'

# Ping test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::PingTest < Minitest::Test
  def test_when_exists
    stub_request(:any, 'https://www.yegor256.com/about-me.html').to_return(body: 'Hello!')
    site = GptTranslate::FakeSite.new({ 'url' => 'https://www.yegor256.com/' })
    ping = GptTranslate::Ping.new(site, '/about-me.html')
    refute_nil(ping.download)
  end

  def test_when_not_exists
    stub_request(:any, 'https://www.yegor256.com/absent.html').to_return(status: 404)
    site = GptTranslate::FakeSite.new({ 'url' => 'https://www.yegor256.com/' })
    ping = GptTranslate::Ping.new(site, '/absent.html')
    assert_nil(ping.download)
  end

  def test_wrong_address
    WebMock.allow_net_connect!
    site = GptTranslate::FakeSite.new({ 'url' => 'https://localhost:1/' })
    ping = GptTranslate::Ping.new(site, '/boom.html')
    assert_nil(ping.download)
  end

  def test_relative_path
    assert_raises(StandardError) do
      GptTranslate::Ping.new({}, '404.html')
    end
  end
end
