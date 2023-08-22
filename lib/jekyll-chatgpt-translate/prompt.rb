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

require 'iso-639'

# The module we are in.
module GptTranslate; end

# Prompt for ChatGPT.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
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
    raise "Unknown source language ISO-639 code: \"#{@source}\"" if from.nil?
    to = ISO_639.find_by_code(@target)
    raise "Unknown source language ISO-639 code: \"#{@target}\"" if to.nil?
    head = [
      'Please, translate the following Markdown paragraph from ',
      from[3],
      ' to ',
      to[3],
      ', don\'t change proper nouns'
    ].join
    "#{head}:\n\n#{@par}"
  end
end
