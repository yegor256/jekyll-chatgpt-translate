# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
