# frozen_string_literal: true

# Copyright (c) 2023-2024 Yegor Bugayenko
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'tmpdir'
require 'English'

Before do
  @cwd = Dir.pwd
  @dir = Dir.mktmpdir('test')
  FileUtils.mkdir_p(@dir)
  Dir.chdir(@dir)
end

After do
  Dir.chdir(@cwd)
  FileUtils.rm_rf(@dir)
end

Given(/^I have a "([^"]*)" file with content:$/) do |file, text|
  FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(file)
  File.write(file, text.gsub('\\xFF', 0xFF.chr))
end

When('I build Jekyll site') do
  @stdout = `jekyll build`
  @exitstatus = $CHILD_STATUS.exitstatus
end

Then('Stdout contains {string}') do |string|
  raise "STDOUT doesn't contain '#{string}':\n#{@stdout}" unless @stdout.include?(string)
end

Then('File {string} exists') do |string|
  raise "The file \"#{string}\" is absent:\n#{`tree -s`}" unless File.exist?(string)
end

Then('File {string} doesn\'t exist') do |string|
  raise "The file \"#{string}\" is present:\n#{`tree -s`}" if File.exist?(string)
end

Then('File {string} contains {string}') do |string, string2|
  raise "The file \"#{string}\" is absent" unless File.exist?(string)
  content = File.read(string)
  raise "The file \"#{string}\" doesn't contain \"#{string2}\":\n#{content}" unless content.include?(string2)
end

Then('Exit code is zero') do
  raise "Non-zero exit #{@exitstatus}:\n#{@stdout}" unless @exitstatus.zero?
end

Then('Exit code is not zero') do
  raise 'Zero exit code' if @exitstatus.zero?
end

When('I run bash with {string}') do |string|
  @stdout = `#{string}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

When(/^I run bash with:$/) do |text|
  @stdout = `#{text}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

When('I copy this gem into temp dir') do
  FileUtils.copy_entry(@cwd, File.join(@dir, 'jekyll-chatgpt-translate'))
end

Given('It is Unix') do
  pending if Gem.win_platform?
end

Given('It is Windows') do
  pending unless Gem.win_platform?
end
