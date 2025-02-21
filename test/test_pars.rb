# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
