# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require_relative 'test__helper'
require_relative '../lib/jekyll-chatgpt-translate/plain'

# Plain test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::PlainTest < Minitest::Test
  def test_simple_map
    assert_equal('Hello, **world**!', GptTranslate::Plain.new("Hello,\n**world**!").to_s)
    assert_equal('Hello, [world](/x.html)!', GptTranslate::Plain.new("Hello,\n[world](/x.html)!").to_s)
    assert_equal('Hello, *Jeff*!', GptTranslate::Plain.new('Hello, _Jeff_!').to_s)
    # assert_equal('Hello, Walter!', GptTranslate::Plain.new('Hello, ~Walter~!').to_s)
    assert_equal("Hi\n\nBye", GptTranslate::Plain.new("  Hi\n\nBye\n\n\n").to_s)
    assert_equal('Hi, dude!', GptTranslate::Plain.new("  Hi,\ndude!\n").to_s)
  end

  def test_strip_meta_markup
    assert_equal('Hello, world!', GptTranslate::Plain.new("{:name='boom'}\nHello, world!").to_s)
    assert_equal('Hello, world!', GptTranslate::Plain.new("Hello, world!\n{: .foo-class}").to_s)
  end

  def test_lists
    assert_equal(
      "* first\n\n* second\n\n* third",
      GptTranslate::Plain.new("* first\n\n* second\n\n* third").to_s
    )
    assert_equal(
      '* first',
      GptTranslate::Plain.new("* first\n\n\n\n").to_s
    )
  end

  def test_ordered_list
    assert_equal(
      "1. first\n\n1. second\n\n1. third",
      GptTranslate::Plain.new("1. first\n\n2. second\n\n3. third").to_s
    )
  end

  def test_compact_list
    assert_equal(
      "* first\n\n* second\n\n* third",
      GptTranslate::Plain.new("* first\n* second\n* third").to_s
    )
  end

  def test_links
    assert_equal(
      'Hello, [dude](/a.html)!',
      GptTranslate::Plain.new('Hello, [dude](/a.html)!').to_s
    )
    assert_equal(
      'Hello, dude!',
      GptTranslate::Plain.new('Hello, [dude]()!').to_s
    )
    assert_equal(
      'Hello, dude!',
      GptTranslate::Plain.new('Hello, [dude]({% post_url 2023-01-01-hello %})!').to_s
    )
  end

  def test_quote
    assert_equal(
      "He said this:\n\n> Life is great!",
      GptTranslate::Plain.new("He said this:\n\n\n> Life is great!\n\n").to_s
    )
  end

  def test_code
    assert_equal(
      'Hello, `Java`!',
      GptTranslate::Plain.new('Hello, `Java`!').to_s
    )
  end

  def test_code_block
    assert_equal(
      "```\na\na\na\na\na\na\na\n\n```",
      GptTranslate::Plain.new("```\na\na\na\na\na\na\na\n\n```").to_s
    )
    assert_equal(
      "Hello:\n\n```\nJava\n```",
      GptTranslate::Plain.new("Hello:\n\n```\nJava\n```\n").to_s
    )
    assert_equal(
      "```\nHello\n```",
      GptTranslate::Plain.new("```\nHello\n```").to_s
    )
    assert_equal(
      "```\nprint('hi!')\n```",
      GptTranslate::Plain.new("```java\nprint('hi!')\n```").to_s
    )
  end

  def test_code_block_with_empty_lines_inside
    assert_equal(
      "```\n\nhello\n\nworld!\n\n```",
      GptTranslate::Plain.new("```\n\nhello\n\n\n\nworld!\n\n```").to_s
    )
  end

  def test_titles
    assert_equal('# Hello', GptTranslate::Plain.new('# Hello').to_s)
    assert_equal('## Hello', GptTranslate::Plain.new('## Hello').to_s)
    assert_equal('### Hello', GptTranslate::Plain.new('### Hello').to_s)
  end

  def test_image
    assert_equal('![alt](a.png "hello")', GptTranslate::Plain.new('![alt](a.png "hello")').to_s)
  end

  def test_html
    assert_equal(
      'This is picture: <img src="a"/>!',
      GptTranslate::Plain.new('This is picture: <img src="a"/>!').to_s
    )
    assert_equal('<img src="a"/>', GptTranslate::Plain.new('<img src="a"/>').to_s)
  end

  def test_html_hr
    md = "First\n\n<hr/>\n\nsecond!"
    assert_equal(md, GptTranslate::Plain.new(md).to_s)
  end

  def test_liquid_tags
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, {{ Java }}!').to_s
    )
    assert_equal(
      'Hello, dude !',
      GptTranslate::Plain.new('Hello, {% if a %} dude {% endif %}!').to_s
    )
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, {% Java %}!').to_s
    )
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, {% plantuml "width=50%" %}!').to_s
    )
  end

  def test_html_comments
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new('Hello, <!-- Java -->!').to_s
    )
    assert_equal(
      'Hello, !',
      GptTranslate::Plain.new("Hello, <!-- \nJava\n -->!").to_s
    )
  end

  def test_big_text
    expected = "Hi, dear **friend**!

In this *lovely* letter I will explain how objects work in C++:

* Declare a class

* Make an instance of it

* Delete the instance

## More details

Something like this:

```
class Foo {};
Foo f = Foo();
```

And then use `new` and `delete` like this:

```
Foo* f = new Foo();
delete f;
```

Should work!"
    input = "
Hi, dear **friend**!

In this _lovely_ letter I will
explain how objects
work in C++:

  * \tDeclare a class
  * \tMake an instance of it
  * \tDelete the instance

## More details

Something like this:

```
class Foo {};
Foo f = Foo();
```

And then use `new` and `delete` like this:

```cpp
Foo* f = new Foo();
delete f;
```

Should work!
"
    assert_equal(expected, GptTranslate::Plain.new(input).to_s)
  end
end
