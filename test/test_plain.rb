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
require_relative '../lib/jekyll-chatgpt-translate/plain'

# Plain test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::PlainTest < Minitest::Test
  def test_simple_map
    assert_equal('Hello, world!', GptTranslate::Plain.new('Hello, **world**!').to_s)
    assert_equal('Hello, Jeff!', GptTranslate::Plain.new('Hello, _Jeff_!').to_s)
    assert_equal("Hi\n\nBye", GptTranslate::Plain.new("  Hi\n\nBye\n\n\n").to_s)
  end

  def test_lists
    assert_equal(
      "first\n\nsecond\n\nthird",
      GptTranslate::Plain.new("* first\n\n* second\n\n* third").to_s
    )
    assert_equal(
      'first',
      GptTranslate::Plain.new("* first\n\n\n\n").to_s
    )
  end

  def test_ordered_list
    assert_equal(
      "first\n\nsecond\n\nthird",
      GptTranslate::Plain.new("1. first\n\n2. second\n\n3. third").to_s
    )
  end

  def test_compact_list
    assert_equal(
      "first\n\nsecond\n\nthird",
      GptTranslate::Plain.new("* first\n* second\n* third").to_s
    )
  end

  def test_links
    assert_equal(
      'Hello, dude!',
      GptTranslate::Plain.new('Hello, [dude](https://www.google.com)!').to_s
    )
  end

  def test_code
    assert_equal(
      'Hello, Java!',
      GptTranslate::Plain.new('Hello, `Java`!').to_s
    )
  end

  def test_code_block
    assert_equal(
      "Hello:\n\nJava",
      GptTranslate::Plain.new("Hello:\n\n```\nJava\n```\n").to_s
    )
  end

  def test_html
    assert_equal(
      'This is picture: HTML!',
      GptTranslate::Plain.new('This is picture: <img src="a"/>!').to_s
    )
    assert_equal('HTML', GptTranslate::Plain.new('<img src="a"/>').to_s)
  end

  def test_liquid_tags
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, {{ Java }}!').to_s
    )
    assert_equal(
      'Hello,  dude !',
      GptTranslate::Plain.new('Hello, {% if a %} dude {% endif %}!').to_s
    )
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, {% Java %}!').to_s
    )
  end
end
