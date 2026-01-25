# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 3.0'
  s.name = 'jekyll-chatgpt-translate'
  s.version = '0.3.0'
  s.license = 'MIT'
  s.summary = 'Translate Jekyll Pages Through ChatGPT'
  s.description = [
    'Add this plugin to your Jekyll site and all posts will be automatically',
    'translated to the languages of your choice through ChatGPT'
  ].join(' ')
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/yegor256/jekyll-chatgpt-translate'
  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = %w[README.md LICENSE.txt]
  s.add_dependency 'base64', '~>0.3'
  s.add_dependency 'elapsed', '~>0.2'
  s.add_dependency 'humanize', '~>3.1'
  s.add_dependency 'iri', '~>0.11'
  s.add_dependency 'iso-639', '~>0.3'
  s.add_dependency 'jekyll', '>= 3.0', '< 5.0'
  s.add_dependency 'json', '~>2.18'
  s.add_dependency 'redcarpet', '~>3.6'
  s.add_dependency 'ruby-openai', '~>8.3'
  s.add_dependency 'tiktoken_ruby', '~>0.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
