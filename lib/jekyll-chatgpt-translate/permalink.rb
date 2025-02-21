# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'cgi'

# The module we are in.
module GptTranslate; end

# Permalink.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class GptTranslate::Permalink
  def initialize(doc, template)
    @doc = doc
    raise 'permalink must be defined for each target' if template.nil?
    @template = template
  end

  def to_path
    path = @template
      .gsub(':year', format('%04d', @doc['date'].year))
      .gsub(':month', format('%02d', @doc['date'].month))
      .gsub(':day', format('%02d', @doc['date'].day))
      .gsub(':title', CGI.escape(@doc['title']))
      .gsub(':slug', CGI.escape(@doc['slug']))
    path = "/#{path}" unless path.start_with?('/')
    path
  end
end
