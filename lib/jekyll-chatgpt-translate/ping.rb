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

require 'iri'
require 'net/http'
require 'uri'
require 'fileutils'
require_relative 'version'

# see https://stackoverflow.com/a/6048451/187141
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# The module we are in.
module GptTranslate; end

# Ping one page of a site.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class GptTranslate::Ping
  # Ctor.
  def initialize(site, path)
    @site = site
    raise 'Permalink must start with a slash' unless path.start_with?('/')
    @path = path
  end

  def found?(file, marker)
    home = @site.config['url']
    return false if home.nil?
    uri = Iri.new(home).path(@path).to_s
    begin
      before = Net::HTTP.get_response(URI(uri))
      if before.is_a?(Net::HTTPSuccess)
        html = before.body
        if html.include?(marker)
          Jekyll.logger.info("No need to translate, the page exists at \
#{uri.inspect} (#{html.split.count} words), saved to #{file.inspect}")
          FileUtils.mkdir_p(File.dirname(file))
          File.write(file, html)
          return true
        end
        Jekyll.logger.info("Re-translation required for #{uri.inspect}")
      else
        Jekyll.logger.info("The page is absent, will translate #{uri.inspect} (#{before.code})")
      end
      Jekyll.logger.debug("GET #{uri.inspect}: #{before.code}")
    rescue StandardError => e
      Jekyll.logger.debug("Failed to ping #{uri.inspect}: #{e.message}")
      Jekyll.logger.info("The page is absent (#{e.class.name}): #{uri.inspect}")
    end
    false
  end
end
