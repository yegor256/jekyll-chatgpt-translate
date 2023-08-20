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
    @site = site
    key = ENV.fetch('OPENAI_API_KEY', nil)
    if key.nil? && Jekyll.env == 'development'
      Jekyll.logger.info('OPENAI_API_KEY environment variable is not set and
we are in development mode, no actual translation will happen,
but pages will be generated')
      key = ''
    end
    if key.nil?
      Jekyll.logger.info('jekyll-chatgpt-translate requires OPENAI_API_KEY environment variable')
      return
    end
    layout = config['layout'] || 'translated'
    start = Time.now
    total = 0
    site.posts.docs.each do |doc|
      plain = GptTranslate::Plain.new(doc.content).to_s
      config['targets'].each do |target|
        link = permalink(doc, target['permalink'])
        next if GptTranslate::Ping.new(site, link).exists?
        lang = target['language']
        raise 'Language must be defined for each target' if target.nil?
        model = config['model'] || 'gpt-3.5-turbo'
        gpt = GptTranslate::ChatGPT.new(
          key,
          model,
          config['source'] || 'en',
          lang
        )
        translated = gpt.translate(plain)
        path = "_chatgpt-translated/#{doc.basename}"
        FileUtils.mkdir_p(File.dirname(path))
        File.write(
          path,
          [
            '---',
            "layout: #{target['layout'] || layout}",
            "title: #{doc.data['title']}",
            "permalink: #{link}",
            '---',
            '',
            translated,
            '',
            "Translated by ChatGPT #{model}/#{GptTranslate::VERSION}\n{: .jekyll-chatgpt-translate}"
          ].join("\n")
        )
        site.pages << Jekyll::Page.new(site, site.source, File.dirname(path), File.basename(path))
        total += 1
      end
    end
    Jekyll.logger.info("#{total} pages generated in #{(Time.now - start).round(2)}s")
  end

  private

  # Returns the plugin's config or an empty hash if not set
  def config
    @config ||= @site.config['chatgpt-translate'] || {}
  end

  def permalink(doc, template)
    raise 'permalink must be defined for each target' if template.nil?
    template
      .gsub(':year', format('%04d', doc['date'].year))
      .gsub(':month', format('%02d', doc['date'].month))
      .gsub(':day', format('%02d', doc['date'].day))
      .gsub(':title', doc['title'])
  end
end
