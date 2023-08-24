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

require 'redcarpet'

# The module we are in.
module GptTranslate; end

# Markdown to plain text.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::Plain
  # Ctor.
  def initialize(markdown)
    @markdown = markdown
  end

  # Liquid tags are removed, but this implementation is primitive
  # Seehttps://stackoverflow.com/questions/
  def to_s
    Redcarpet::Markdown.new(Strip).render(
      @markdown
        .gsub(/([^\n])\n(\s*\* )/, "\\1\n\n\\2")
        .gsub(/<!--.+?-->/m, '')
        .gsub(/{{[^}]+}}/, '')
        .gsub(/{%.+?%}/, '')
    ).strip
  end

  # Markdown to pain text.
  # Motivated by https://github.com/vmg/redcarpet/blob/master/lib/redcarpet/render_strip.rb
  class Strip < Redcarpet::Render::Base
    %i[
      block_quote
      block_html
      autolink
      underline
      triple_emphasis
      strikethrough
      superscript highlight quote
      footnotes footnote_def footnote_ref
      entity normal_text
    ].each do |method|
      define_method method do |*args|
        args.first
      end
    end

    def double_emphasis(txt)
      "**#{txt}**"
    end

    def block_code(code, _lang)
      code
    end

    def emphasis(txt)
      "*#{txt}*"
    end

    def header(text, level)
      "#{'#' * level} #{text}\n\n"
    end

    def codespan(content)
      if content.start_with?("\n")
        "```#{content}```"
      elsif content.end_with?("\n")
        "```\n#{content.split("\n", 2)[1]}```"
      else
        "`#{content}`"
      end
    end

    def image(link, title, alt)
      "![#{alt}](#{link} \"#{title}\")"
    end

    def raw_html(html)
      html
    end

    def list(content, _type)
      content
    end

    def list_item(content, type)
      "#{type == :ordered ? '1.' : '*'} #{content.strip}\n\n"
    end

    def paragraph(text)
      unless text.start_with?('```')
        text.gsub!(/\n+/, ' ')
        text.gsub!(/\s{2,}/, ' ')
      end
      "#{text}\n\n"
    end

    def link(link, _title, content)
      "[#{content}](#{link})"
    end
  end
end
