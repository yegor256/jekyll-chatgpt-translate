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
require 'webmock/minitest'
require 'jekyll'
require 'tempfile'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/ping'

# Ping test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::PingTest < Minitest::Test
  def test_when_exists
    stub_request(:any, 'https://www.yegor256.com/about-me.html').to_return(body: 'Hello!')
    site = GptTranslate::FakeSite.new({ 'url' => 'https://www.yegor256.com/' })
    ping = GptTranslate::Ping.new(site, '/about-me.html')
    assert(!ping.download.nil?)
  end

  def test_when_not_exists
    stub_request(:any, 'https://www.yegor256.com/absent.html').to_return(status: 404)
    site = GptTranslate::FakeSite.new({ 'url' => 'https://www.yegor256.com/' })
    ping = GptTranslate::Ping.new(site, '/absent.html')
    assert(ping.download.nil?)
  end

  def test_wrong_address
    WebMock.allow_net_connect!
    site = GptTranslate::FakeSite.new({ 'url' => 'https://localhost:1/' })
    ping = GptTranslate::Ping.new(site, '/boom.html')
    assert(ping.download.nil?)
  end

  def test_relative_path
    assert_raises do
      GptTranslate::Ping.new({}, '404.html')
    end
  end
end
