# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'jekyll'
require 'fileutils'
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
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::Generator < Jekyll::Generator
  safe true
  priority :lowest

  # Main plugin action, called by Jekyll-core
  def generate(site)
    if ARGV.include?('--offline')
      Jekyll.logger.info("jekyll-chatgpt-translate #{GptTranslate::VERSION} skipped, due to the --offline option")
      return
    end
    Jekyll.logger.info("jekyll-chatgpt-translate #{GptTranslate::VERSION} starting...")
    config ||= site.config['chatgpt-translate'] || {}
    home = config['tmpdir'] || '_chatgpt-translate'
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
    site.posts.docs.shuffle.each_with_index do |doc, pos|
      plain = GptTranslate::Plain.new(doc.content).to_s
      layout = doc['layout']
      config['targets'].each do |target|
        pstart = Time.now
        link = GptTranslate::Permalink.new(doc, target['permalink']).to_path
        lang = target['language']
        raise 'Language must be defined for each target' if target.nil?
        only = target['only']
        if !only.nil? && layout != only
          Jekyll.logger.debug("Not translating #{link.inspect}, b/c 'only' set to '#{only}'")
          next
        end
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
            'chatgpt-translate:',
            "  original-url: #{doc.url.to_json}",
            "  language: #{lang.to_json}",
            "  model: #{model.to_json}",
            '---'
          ].join("\n")
        )
        html = config['no_download'].nil? ? GptTranslate::Ping.new(site, link).download : nil
        needed = false
        added = false
        if html.nil?
          Jekyll.logger.info("The page is absent, need to translate #{link.inspect}")
          needed = true
        else
          copied += 1
          site.static_files << DownloadedFile.new(site, link, html)
          added = true
          if version.empty?
            Jekyll.logger.info("Re-translation not required, since version is empty: #{link.inspect}")
          elsif html.include?(marker)
            Jekyll.logger.info("No need to translate, the page exists at \
#{link.inspect} (#{html.split.count} words)")
          else
            Jekyll.logger.info("Re-translation required for #{link.inspect}")
            needed = true
          end
        end
        if translated >= threshold
          Jekyll.logger.info("Page ##{pos} is ignored, we are over the threshold of #{threshold}: #{link}")
        elsif needed
          gpt = GptTranslate::ChatGPT.new(
            key,
            model,
            target['source'] || config['source'] || 'en',
            lang
          )
          foreign = gpt.translate(
            plain,
            min: min_chars,
            window_length: (config['window_length'] || '2048').to_i
          )
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
          site.static_files.delete_if { |f| f.is_a?(DownloadedFile) && f.link == link }
          added = true
          translated += 1
          Jekyll.logger.info("Translated via ChatGPT \
in #{(Time.now - pstart).round(2)}s: #{path} (#{File.size(path)} bytes)")
        end
        next unless added
        doc.data['chatgpt-translate'] ||= {}
        doc.data['chatgpt-translate']['model'] ||= model
        doc.data['chatgpt-translate']['urls'] ||= {}
        doc.data['chatgpt-translate']['urls'][lang] = link
      end
    end
    Jekyll.logger.info("jekyll-chatgpt-translate #{GptTranslate::VERSION}: \
#{translated} pages translated and #{copied} pages copied in #{(Time.now - start).round(2)}s")
  end

  # The file we just downloaded.
  class DownloadedFile < Jekyll::StaticFile
    attr_reader :link

    def initialize(site, link, html)
      super(site, site.dest, '', link)
      @html = html
      @link = link
    end

    def write(_dest)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, @html)
      Jekyll.logger.info("Saved #{@html.split.count} words to #{path.inspect}")
      true
    end
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
    if key.nil? && config['api_key']
      Jekyll.logger.info("The OpenAI API key is found in 'api_key' of _config.yml")
      key = config['api_key']
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
