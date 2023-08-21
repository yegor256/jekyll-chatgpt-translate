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
    threshold = config['threshold'] || 1_000_000_000
    start = Time.now
    total = 0
    site.posts.docs.each do |doc|
      plain = GptTranslate::Plain.new(doc.content).to_s
      config['targets'].each do |target|
        link = GptTranslate::Permalink.new(doc, target['permalink']).to_path
        next if GptTranslate::Ping.new(site, link).found?(doc.path)
        lang = target['language']
        raise 'Language must be defined for each target' if target.nil?
        model = config['model'] || 'gpt-3.5-turbo'
        if total >= threshold
          Jekyll.logger.info("Already generated #{total} pages, that's enough for today")
          break
        end
        gpt = GptTranslate::ChatGPT.new(
          key,
          model,
          config['source'] || 'en',
          lang
        )
        translated = gpt.translate(plain)
        path = File.join(home, lang, doc.basename.gsub(/\.md$/, "-#{lang}.md"))
        FileUtils.mkdir_p(File.dirname(path))
        File.write(
          path,
          [
            '---',
            "layout: #{target['layout'] || layout}",
            "title: #{doc.data['title']}",
            "permalink: #{link}",
            "translated-original-url: #{doc.url}",
            '---',
            '',
            translated,
            '',
            "Translated by ChatGPT #{model}/#{GptTranslate::VERSION}\n{: .jekyll-chatgpt-translate}"
          ].join("\n")
        )
        doc.data["translated-#{lang}-url"] = link
        site.pages << Jekyll::Page.new(site, site.source, File.dirname(path), File.basename(path))
        total += 1
        Jekyll.logger.info("Translated via ChatGPT: #{path}")
      end
      break if total >= threshold
    end
    Jekyll.logger.info("#{total} pages translated in #{(Time.now - start).round(2)}s")
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
      Jekyll.logger.info("Reading OpenAI key from the file: #{file}")
      File.read(file).strip
    else
      Jekyll.logger.info("The file is not found: #{file}")
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
