# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/permalink'

# Permalink test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
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
