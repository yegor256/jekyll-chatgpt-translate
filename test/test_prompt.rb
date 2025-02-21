# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/prompt'

# Prompt test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::PromptTest < Minitest::Test
  def head(source, target)
    [
      'Please, translate the following Markdown paragraph',
      " from #{source} to #{target},",
      " don't translate technical terms and proper nouns"
    ].join
  end

  def test_english_to_russian
    assert_equal(
      "#{head('English', 'Russian')}:\n\nHello, dude, how are you doing today in this fair city?",
      GptTranslate::Prompt.new('Hello, dude, how are you doing today in this fair city?', 'en', 'ru').to_s
    )
  end

  def test_english_to_chinese
    assert_equal(
      "#{head('English', 'Chinese')}: \"Hello, Jeff!\"",
      GptTranslate::Prompt.new('Hello, Jeff!', 'en', 'zh').to_s
    )
  end

  def test_multiple_paragraphs
    assert(
      GptTranslate::Prompt.new("Hello,\n\nJeff!", 'en', 'zh').to_s.include?("\"Hello,\n\nJeff!\"")
    )
  end
end
