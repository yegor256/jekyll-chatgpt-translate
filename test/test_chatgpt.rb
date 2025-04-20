# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'webmock/minitest'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/chatgpt'

# ChatGPT test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::ChatGPTTest < Minitest::Test
  def test_short_text
    chat = GptTranslate::ChatGPT.new('fake-key', 'foo', 'xx', 'zz')
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
    chat = GptTranslate::ChatGPT.new('', 'foo', 'xx', 'zz')
    assert_equal(38, chat.translate('This text should not be sent to OpenAI', min: 100).length)
  end

  def test_no_translation
    chat = GptTranslate::ChatGPT.new('', 'foo', 'xx', 'zz')
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
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'xx', 'zz')
    assert_equal('<img src="a"/>', chat.translate('<img src="a"/>', min: 1))
  end

  def test_image
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'xx', 'zz')
    assert_equal('![some image](/foo.png)', chat.translate('![some image](/foo.png)', min: 1))
  end

  def test_code_block
    chat = GptTranslate::ChatGPT.new('fake-key', '', 'xx', 'zz')
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
        min: 1, window_length: 4
      )
    )
  end

  def test_with_json
    client = Object.new
    def client.chat(*)
      { 'choices' => [{ 'message' => { 'content' => 'done!' } }] }
    end
    chat = GptTranslate::ChatGPT.new('fake-key', 'gpt-3.5-turbo', 'en', 'ru', client: client)
    assert_equal(
      "done!\n\ndone!",
      chat.translate(
        "This is the first paragraph\n\nThis is second\n\nThis is third",
        min: 1, window_length: 4
      )
    )
  end

  private

  def stub_it!
    url = "#{api_base_url}v1/chat/completions"
    stub_request(:any, url).to_return(
      body: '{"choices":[{"message":{"content": "done!"}}]}'
    )
  end

  def api_base_url
    url = ENV.fetch('OPENAI_API_BASE', 'https://api.openai.com/')
    Jekyll.logger.info("Current OpenAI API Base URL: #{url.inspect}")

    warning_msg = 'Warning: You\'re using a custom endpoint for the OpenAI API. ' \
                  'The provider of this endpoint may have access to all details ' \
                  'of your requests. Only use a custom endpoint if you trust the provider.'
    Jekyll.logger.warn(warning_msg) if url != 'https://api.openai.com/'

    url
  end
end
