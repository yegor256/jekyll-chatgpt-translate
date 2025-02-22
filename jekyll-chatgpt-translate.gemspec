# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 3.0'
  s.name = 'jekyll-chatgpt-translate'
  s.version = '0.0.0'
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
  s.add_runtime_dependency 'humanize', '>= 2'
  s.add_runtime_dependency 'iri', '>= 0'
  s.add_runtime_dependency 'iso-639', '>= 0'
  s.add_runtime_dependency 'jekyll', '>= 3'
  s.add_runtime_dependency 'json', '>= 2'
  s.add_runtime_dependency 'redcarpet', '>= 3'
  s.add_runtime_dependency 'ruby-openai', '>= 5'
  s.add_runtime_dependency 'tiktoken_ruby', '>= 0.0.6'
  s.metadata['rubygems_mfa_required'] = 'true'
end
