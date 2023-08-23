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
require_relative 'prompt'

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

  def translate(markdown, min: 32)
    markdown.split(/\n{2,}/).compact.map do |par|
      par.strip!
      if @source == @target
        Jekyll.logger.debug("No need to translate from #{@source.inspect} to #{@target.inspect}: #{par.inspect}")
        par
      elsif par.length < min
        Jekyll.logger.debug("Not translating this, b/c too short: #{par.inspect}")
        par
      elsif par.start_with?('```') || par.end_with?('```')
        Jekyll.logger.debug("Not translating this code block: #{par.inspect}")
        par
      elsif par =~ /^[^\p{Alnum}\*'"]/
        Jekyll.logger.debug("Not translating this, b/c it's not a plain text: #{par.inspect}")
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
    answer = nil
    attempt = 0
    begin
      prompt = GptTranslate::Prompt.new(par, @source, @target).to_s
      response = OpenAI::Client.new(access_token: @key).chat(
        parameters: {
          model: @model,
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.7
        }
      )
      answer = response.dig('choices', 0, 'message', 'content')
      Jekyll.logger.debug("ChatGPT prompt: #{prompt.inspect}, ChatGPT answer: #{answer.inspect}")
    rescue StandardError => e
      attempt += 1
      if attempt < 4
        Jekyll.logger.error("ChatGPT failed to answer to #{prompt.inspect} \
(attempt no.#{attempt}): #{e.message.inspect}")
        retry
      end
      raise e
    end
    Jekyll.logger.info("Translated #{par.split.count} #{@source.upcase} words \
to #{answer.split.count} #{@target.upcase} words \
through #{@model} in #{(Time.now - start).round(2)}s: #{"#{par[0..24]}...".inspect}")
    answer
  end
end
