# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2023-2024 Yegor Bugayenko
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
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/permalink'

# Permalink test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2024 Yegor Bugayenko
# License:: MIT
class GptTranslate::PermalinkTest < Minitest::Test
  def test_simple_link
    assert_equal(
      '/2023.html',
      GptTranslate::Permalink.new(
        { 'date' => Time.parse('2023-01-01'), 'title' => 'Hello', 'slug' => 'hello' },
        ':year.html'
      ).to_path
    )
  end

  def test_unicode_link
    assert_equal(
      '/2023-%23%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82.html',
      GptTranslate::Permalink.new(
        { 'date' => Time.parse('2023-01-01'), 'title' => '#привет', 'slug' => 'hello' },
        ':year-:title.html'
      ).to_path
    )
  end
end
