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
require_relative '../lib/jekyll-chatgpt-translate/chatgpt'

# ChatGPT test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::ChatGPTTest < Minitest::Test
  def test_short_text
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal('Hello, world!', chat.translate('Hello, world!'))
  end

  def test_dry_mode
    chat = GptTranslate::ChatGPT.new('', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal(38, chat.translate('This text should not be sent to OpenAI').length)
  end

  def test_markup
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal('<img src="a"/>', chat.translate('<img src="a"/>'))
  end

  def test_through_webmock
    stub_request(:any, 'https://api.openai.com/v1/chat/completions')
      .to_return(body: '{"choices":[{"message":{"content": "boom!"}}]}')
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal('boom!', chat.translate('This is the text to send to OpenAI'))
  end
end
