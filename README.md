[![rake](https://github.com/yegor256/jekyll-chatgpt-translate/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/jekyll-chatgpt-translate/actions/workflows/rake.yml)
[![Gem Version](https://badge.fury.io/rb/jekyll-chatgpt-translate.svg)](http://badge.fury.io/rb/jekyll-chatgpt-translate)

Install it first:

```
gem install jekyll-chatgpt-translate
```

Then, add this to `_config.yml`:

```yaml
chatgpt-translate:
  model: gpt-3.5-turbo
  source: en
  layout: translated
  targets: 
    - 
      language: cn
      permalink: :year-:month-:day-:title-chinese.html
      layout: chinese-translated
    - 
      language: fr
      permalink: :year-:month-:day-:title-french.html
```

Here, the source language is English (`en`), the target one is Chinese (`cn`),
the layout is `_layout/translated.html` (you must have this file).

OpenAI API KEY must be set in `OPENAI_API_KEY` environment variable, otherwise
the plugin will not do any translation and won't generate translated pages. 
You can get your key [here](https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key).

The plugin is compatible with 
[Jekyll 3.9.3](https://jekyllrb.com/news/2023/01/29/jekyll-3-9-3-released/) and 
[Jekyll 4.3.2](https://jekyllrb.com/news/2023/01/20/jekyll-4-3-2-released/). 

# How to Contribute

Test is like this:

```bash
$ bundle update
$ bundle exec rake
```

If it works, make changes, test again, and then submit a pull request.
