# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2023-2025 Yegor Bugayenko
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
require_relative 'version'

# see https://stackoverflow.com/a/6048451/187141
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# The module we are in.
module GptTranslate; end

# Ping one page of a site.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::Ping
  # Ctor.
  def initialize(site, path)
    @site = site
    raise 'Permalink must start with a slash' unless path.start_with?('/')
    @path = path
  end

  # Downloads the page from the Internet and returns HTML or NIL, if the page is absent
  def download
    home = @site.config['url']
    return nil if home.nil?
    uri = Iri.new(home).path(@path).to_s
    html = nil
    begin
      response = Net::HTTP.get_response(URI(uri))
      html = response.body if response.is_a?(Net::HTTPSuccess)
      Jekyll.logger.debug("GET #{uri.inspect}: #{response.code}")
    rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL => e
      Jekyll.logger.debug("Failed to ping #{uri.inspect} (#{e.class.name}): #{e.message}")
    end
    html
  end
end
