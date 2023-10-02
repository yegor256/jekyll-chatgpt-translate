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
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/chatgpt'

# ChatGPT test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::ChatGPTTest < Minitest::Test
  def test_short_text
    chat = GptTranslate::ChatGPT.new('fake-key', 'foo', 'xx', 'xx')
    assert_equal('Hello, world!', chat.translate('Hello, world!'))
  end

  def test_start_with_link
    stub_it!
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal('done!', chat.translate('[OpenAI](https://openai.com) is the creator of ChatGPT', min: 10))
  end

  def test_unordered_list_item
    stub_it!
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal("* done!\n\n* done!", chat.translate("* First\n\n* Second", min: 1))
  end

  def test_ordered_list_item
    stub_it!
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal("1. done!\n\n1. done!", chat.translate("1. First\n\n2. Second", min: 1))
  end

  def test_dry_mode
    chat = GptTranslate::ChatGPT.new('', 'foo', 'xx', 'xx')
    assert_equal(38, chat.translate('This text should not be sent to OpenAI', min: 100).length)
  end

  def test_no_translation
    chat = GptTranslate::ChatGPT.new('', 'foo', 'xx', 'xx')
    chat.translate(
      "
      How are you, my friend? This text must be translated through ChatGPT.

      Read this Java code (this paragraph must also be translated through ChatGPT):

      ```
      System.out.println(\"Hello, dude!\");
      System.out.println(\"Good bye!\");
      System.out.println(\"Done!\");
      ```

      This is it.
      ",
      min: 40,
      window_length: 10
    )
  end

  def test_markup
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'xx', 'xx')
    assert_equal('<img src="a"/>', chat.translate('<img src="a"/>'))
  end

  def test_code_block
    chat = GptTranslate::ChatGPT.new('fake-key', '', 'xx', 'xx')
    chat.translate("```\ntest\n```", min: 0)
  end

  def test_through_webmock
    stub_it!
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal('done!', chat.translate('This is the text to send to OpenAI'))
  end

  def test_through_small_window
    stub_it!
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru')
    assert_equal(
      "done!\n\ndone!",
      chat.translate(
        "This is the first paragraph\n\nThis is second\n\nThis is third",
        min: 1, window_length: 5
      )
    )
  end

  private

  def stub_it!
    stub_request(:any, 'https://api.openai.com/v1/chat/completions')
      .to_return(body: '{"choices":[{"message":{"content": "done!"}}]}')
  end
end
