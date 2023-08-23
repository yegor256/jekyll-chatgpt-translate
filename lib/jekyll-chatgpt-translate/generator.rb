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
require 'json'
require_relative 'chatgpt'
require_relative 'permalink'
require_relative 'ping'
require_relative 'plain'
require_relative 'version'

# The module we are in.
module GptTranslate; end

# Pages generator.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::Generator < Jekyll::Generator
  safe true
  priority :lowest

  # Main plugin action, called by Jekyll-core
  def generate(site)
    config ||= site.config['chatgpt-translate'] || {}
    home = '_chatgpt-translated'
    key = api_key(config)
    if key.nil?
      Jekyll.logger.info('jekyll-chatgpt-translate requires OPENAI_API_KEY environment variable')
      return
    end
    layout = config['layout'] || 'translated'
    version = config['version'] || GptTranslate::VERSION
    threshold = config['threshold'] || 1024
    min_chars = config['min_chars'] || 128
    start = Time.now
    translated = 0
    copied = 0
    model = config['model'] || 'gpt-3.5-turbo'
    marker = "Translated by ChatGPT #{model}#{version.empty? ? '' : "/#{version}"}"
    site.posts.docs.shuffle.each do |doc|
      plain = GptTranslate::Plain.new(doc.content).to_s
      config['targets'].each do |target|
        link = GptTranslate::Permalink.new(doc, target['permalink']).to_path
        lang = target['language']
        raise 'Language must be defined for each target' if target.nil?
        path = File.join(home, lang, doc.basename.gsub(/\.md$/, "-#{lang}.md"))
        FileUtils.mkdir_p(File.dirname(path))
        File.write(
          path,
          [
            '---',
            "layout: #{target['layout'] || layout}",
            "title: #{doc['title'].to_json}",
            "description: #{doc['description'].to_json}",
            "permalink: #{link.to_json}",
            "translated-original-url: #{doc.url.to_json}",
            "translated-language: #{lang.to_json}",
            "chatgpt-model: #{model.to_json}",
            '---'
          ].join("\n")
        )
        url = Jekyll::Page.new(site, site.source, File.dirname(path), File.basename(path)).url
        ping = GptTranslate::Ping.new(site, link)
        if config['no_download'].nil? && ping.found?(File.join(site.dest, url), version.empty? ? '' : marker)
          copied += 1
        elsif translated >= threshold
          next
        else
          gpt = GptTranslate::ChatGPT.new(
            key,
            model,
            config['source'] || 'en',
            lang
          )
          foreign = gpt.translate(plain, min: min_chars)
          File.write(
            path,
            [
              '',
              foreign,
              '',
              "#{marker} on #{Time.now.strftime('%Y-%m-%d at %H:%M')}\n{: .jekyll-chatgpt-translate}"
            ].join("\n"),
            mode: 'a+'
          )
          site.pages << Jekyll::Page.new(site, site.source, File.dirname(path), File.basename(path))
          translated += 1
          Jekyll.logger.info("Translated via ChatGPT: #{path} (#{File.size(path)} bytes)")
        end
        doc.data["translated-#{lang}-url"] = link
        doc.data['chatgpt-model'] = model
      end
    end
    Jekyll.logger.info("jekyll-chatgpt-translate #{GptTranslate::VERSION}: \
#{translated} pages translated and #{copied} pages copied in #{(Time.now - start).round(2)}s")
  end

  private

  # Try to find the KEY, either in the environment, a file, etc.
  # If not found, return NIL.
  def api_key(config)
    file = config['api_key_file']
    key = if file.nil?
      k = ENV.fetch('OPENAI_API_KEY', nil)
      Jekyll.logger.info('The key is found in the OPENAI_API_KEY env variable') unless k.nil?
      k
    elsif File.exist?(file)
      k = File.read(file).strip
      Jekyll.logger.info("The OpenAI API key taken from the file: #{file.inspect} (#{k.length} chars)")
      k
    else
      Jekyll.logger.info("The file with the OpenAI API key is not found: #{file.inspect}")
      nil
    end
    if key.nil? && Jekyll.env == 'development'
      Jekyll.logger.info("OPENAI_API_KEY environment variable is not set, \
the `api_key_file` option is not specified in the _config.yml, and \
we are in development mode, that's why no actual translation will happen, \
but .md pages will be generated")
      key = ''
    end
    key
  end
end
