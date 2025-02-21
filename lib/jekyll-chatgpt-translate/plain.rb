# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'redcarpet'

# The module we are in.
module GptTranslate; end

# Markdown to plain text.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
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
        .gsub(/([^\n])\n(\s*\* )/, "\\1\n\n\\2") # condensed list into item-per-par
        .gsub(/<!--.+?-->/m, '')
        .gsub(/{{[^}]+}}/, '')
        .gsub(/{%.+?%}/, '')
        .gsub(/^\{.+?\}\n/, '')
        .gsub(/\n\{.+?\}$/, '')
    ).strip
  end

  # Markdown to pain text.
  # Motivated by https://github.com/vmg/redcarpet/blob/master/lib/redcarpet/render_strip.rb
  class Strip < Redcarpet::Render::Base
    %i[
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

    def block_quote(txt)
      "> #{txt}"
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

    def block_html(html)
      "#{html}\n"
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
      if !link.nil? && link.start_with?('/', 'https://', 'http://')
        "[#{content}](#{link})"
      else
        content
      end
    end
  end
end
