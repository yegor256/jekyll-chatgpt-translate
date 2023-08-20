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

# module Jekyll; end
module Jekyll::Translate; end

# Pages generator.
class Jekyll::Translate::Generator < Jekyll::Generator
  safe true
  priority :lowest

  # Main plugin action, called by Jekyll-core
  def generate(site)
    @site = site
    if disabled_in_development?
      Jekyll.logger.info('Jekyll ChatGPT Translate:', 'Skipping feed generation in development')
      return
    end
    # collections.each do |name, meta|
    #   Jekyll.logger.info "Jekyll Feed:", "Generating feed for #{name}"
    #   (meta["categories"] + [nil]).each do |category|
    #     path = feed_path(:collection => name, :category => category)
    #     next if file_exists?(path)

    #     @site.pages << make_page(path, :collection => name, :category => category)
    #   end
    # end
    # generate_feed_by_tag if config["tags"] && !@site.tags.empty?
  end

  private

  # Returns the plugin's config or an empty hash if not set
  def config
    @config ||= @site.config["feed"] || {}
  end

  def disabled_in_development?
    config && config["disable_in_development"] && Jekyll.env == 'development'
  end
end
