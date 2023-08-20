[![rake](https://github.com/yegor256/jekyll-chatgpt-translate/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/jekyll-chatgpt-translate/actions/workflows/rake.yml)
[![Gem Version](https://badge.fury.io/rb/jekyll-chatgpt-translate.svg)](http://badge.fury.io/rb/jekyll-chatgpt-translate)

Install it first:

```
gem install jekyll-chatgpt-translate
```

With Jekyll 2, simply add the gem to your `_config.yml` gems list:

```yaml
gems: ['jekyll-chatgpt-translate', ... your other plugins]
```

Or for previous versions,
create a plugin file within your Jekyll project's `_plugins` directory:

```ruby
# _plugins/jekyll-chatgpt-translate.rb
require 'jekyll-chatgpt-translate'
```

Highly recommend to use Bundler. If you're using it, add this line
to your `Gemfile`:

```
gem 'jekyll-chatgpt-translate'
```

The plugin is compatible with 
[Jekyll 3.9.3](https://jekyllrb.com/news/2023/01/29/jekyll-3-9-3-released/) and 
[Jekyll 4.3.2](https://jekyllrb.com/news/2023/01/20/jekyll-4-3-2-released/). 
