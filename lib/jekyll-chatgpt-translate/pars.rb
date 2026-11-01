# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'version'

# Markdown broken down ito pars.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class GptTranslate::Pars
  # Ctor.
  # +markdown+ The markdown
  def initialize(markdown)
    @markdown = markdown
  end

  # Returns an array of strings
  def to_a
    pars = []
    inside = false
    @markdown.strip.split(/\n{2,}/).compact.each do |par|
      if inside
        pars[-1] = "#{pars[-1]}\n\n#{par}"
      else
        pars << par
      end
      inside = true if par.start_with?('```') && !inside
      inside = false if par.end_with?('```') && inside
    end
    pars
  end
end
