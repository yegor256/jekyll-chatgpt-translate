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
require_relative '../lib/jekyll-chatgpt-translate/prompt'

# Prompt test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::PromptTest < Minitest::Test
  def par(body, source, target)
    [
      'Please, translate the following Markdown paragraph',
      " from #{source} to #{target},",
      " don't change proper nouns:\n\n#{body}"
    ].join
  end

  def test_english_to_russian
    assert_equal(
      par('Hello, dude!', 'English', 'Russian'),
      GptTranslate::Prompt.new('Hello, dude!', 'en', 'ru').to_s
    )
  end

  def test_english_to_chinese
    assert_equal(
      par('Hello, Jeff!', 'English', 'Chinese'),
      GptTranslate::Prompt.new('Hello, Jeff!', 'en', 'zh').to_s
    )
  end
end
