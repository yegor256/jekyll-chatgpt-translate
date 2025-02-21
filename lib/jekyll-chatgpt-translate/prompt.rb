# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'iso-639'
require 'humanize'

# The module we are in.
module GptTranslate; end

# Prompt for ChatGPT.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::Prompt
  # Ctor.
  # +par+ Text to translate
  # +source+ The language to translate from
  # +target+ The language to translate into
  def initialize(par, source, target)
    @par = par
    @source = source
    @target = target
  end

  def to_s
    from = ISO_639.find_by_code(@source)
    raise "Unknown source language ISO-639 code: #{@source.inspect}" if from.nil?
    to = ISO_639.find_by_code(@target)
    raise "Unknown source language ISO-639 code: #{@target.inspect}" if to.nil?
    md = @par
    parts = md.split("\n\n")
    label = parts.size > 1 ? "#{parts.size.humanize(locale: :en)} Markdown paragraphs" : 'Markdown paragraph'
    head = [
      "Please, translate the following #{label} from ",
      from[3],
      ' to ',
      to[3],
      ', don\'t translate technical terms and proper nouns'
    ].join
    if @par.include?('"') || @par.split.count >= 8
      "#{head}:\n\n#{@par}"
    else
      "#{head}: \"#{@par}\""
    end
  end
end
