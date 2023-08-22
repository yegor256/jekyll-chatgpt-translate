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

require 'jekyll'
require 'openai'
require 'iso-639'

# The module we are in.
module GptTranslate; end

# Abstraction of ChatGPT.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::ChatGPT
  # Ctor.
  # +key+ OpenAI API Key, which can't be nil, but can be empty string, which means dry mode (no calls to OpenAI)
  # +source+ The language to translate from
  # +target+ The language to translate into
  def initialize(key, model, source, target)
    raise 'OpenAI key cannot be nil' if key.nil?
    @key = key
    @model = model
    @source = source
    @target = target
  end

  def translate(text)
    text.split("\n\n").compact.map do |par|
      if par.length <= 32
        Jekyll.logger.debug("Not translating this, b/c too short: \"#{par}\"")
        par
      elsif par !~ /^[a-zA-Zа-яА-Я]/
        Jekyll.logger.debug("Not translating this, b/c it's not a plain text: \"#{par}\"")
        par
      elsif @key.empty?
        par
      else
        translate_par(par)
      end
    end.join("\n\n")
  end

  private

  def translate_par(par)
    start = Time.now
    output = nil
    attempt = 0
    begin
      input = "#{prompt}:\n\n#{par}"
      response = OpenAI::Client.new(access_token: @key).chat(
        parameters: {
          model: @model,
          messages: [{ role: 'user', content: input }],
          temperature: 0.7
        }
      )
      output = response.dig('choices', 0, 'message', 'content')
      Jekyll.logger.info("ChatGPT prompt: \"#{input}\", ChatGPT response #{output}")
    rescue StandardError => e
      attempt += 1
      retry if attempt < 4
      raise e
    end
    Jekyll.logger.info("Translated #{par.split.count} #{@source.upcase} words \
to #{output.split.count} #{@target.upcase} words \
through #{@model} in #{(Time.now - start).round(2)}s")
    output
  end

  def prompt
    [
      'Please, translate this paragraph from',
      ISO_639.find_by_code(@source),
      'to',
      ISO_639.find_by_code(@target),
      ', don\'t change proper nouns'
    ].join(' ')
  end
end
