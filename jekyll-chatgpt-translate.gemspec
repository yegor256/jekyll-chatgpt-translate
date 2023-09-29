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

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 2.6'
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
  s.add_runtime_dependency 'iri', '>= 0'
  s.add_runtime_dependency 'iso-639', '>= 0'
  s.add_runtime_dependency 'jekyll', '>= 3'
  s.add_runtime_dependency 'redcarpet', '>= 3'
  s.add_runtime_dependency 'ruby-openai', '>= 5'
  s.add_runtime_dependency 'humanize', '>= 2'
  s.metadata['rubygems_mfa_required'] = 'true'
end
