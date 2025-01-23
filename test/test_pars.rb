# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2023-2025 Yegor Bugayenko
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
require_relative '../lib/jekyll-chatgpt-translate/pars'

# Test for Pars.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::ParsTest < Minitest::Test
  def test_simple_cases
    assert_equal(1, GptTranslate::Pars.new('Hello, **world**!').to_a.size)
    assert_equal(2, GptTranslate::Pars.new("Hello,\n\n**world**!").to_a.size)
    assert_equal(2, GptTranslate::Pars.new("\n\n\nHello,\n\n**world**\n!\n\n").to_a.size)
  end

  def test_returns_unfrozen_strings
    GptTranslate::Pars.new("Hi, world!\n\n```\ntest\n```\n\nBye\n").to_a.map(&:strip!)
  end

  def test_understands_code_block
    pars = GptTranslate::Pars.new("Hello:\n\n```java\na\n\nb\n\nc\n```\n\nz").to_a
    assert_equal(3, pars.size)
    assert_equal('Hello:', pars[0])
    assert_equal("```java\na\n\nb\n\nc\n```", pars[1])
    assert_equal('z', pars[2])
  end

  def test_understands_empty_block
    pars = GptTranslate::Pars.new("Hello:\n\n```\n```\n\nz").to_a
    assert_equal(3, pars.size)
    assert_equal('Hello:', pars[0])
    assert_equal("```\n```", pars[1])
    assert_equal('z', pars[2])
  end

  def test_understands_empty_block_with_type
    pars = GptTranslate::Pars.new("Hello:\n\n```java\n```\n\nz").to_a
    assert_equal(3, pars.size)
    assert_equal('Hello:', pars[0])
    assert_equal("```java\n```", pars[1])
    assert_equal('z', pars[2])
  end

  def test_understands_two_blocks
    pars = GptTranslate::Pars.new("```java\na\n\nb\n```\n\n```text\na\n\nb\n```").to_a
    assert_equal(2, pars.size)
    assert_equal("```java\na\n\nb\n```", pars[0])
    assert_equal("```text\na\n\nb\n```", pars[1])
  end
end
