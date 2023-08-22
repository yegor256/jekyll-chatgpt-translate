Feature: Simple site building
  I want to be able to build a site

  Scenario: Simple site
    Given I have a "_config.yml" file with content:
    """
    markdown: kramdown
    plugins:
      - jekyll-chatgpt-translate
    chatgpt-translate:
      api_key_file: the-file-is-absent.txt
      source: en
      layout: translated
      targets:
        -
          language: zh
          permalink: :year-:month-:day-:slug-chinese.html
          layout: chinese-translated
        -
          language: fr
          permalink: :year/:slug-french.html
    """
    And I have a "_layouts/default.html" file with content:
    """
    The Chinese: {{ page.translated-zh-url }}
    The French: {{ page.translated-fr-url }}
    {{ content }}
    """
    And I have a "_layouts/chinese-translated.html" file with content:
    """
    Chinese: {{ content }}
    The original: {{ page.translated-original-url }}
    """
    And I have a "_posts/2023-01-01-hello.md" file with content:
    """
    ---
    title: Hello, world!
    layout: default
    ---
    Hello, world!
    """
    Then I build Jekyll site
    And File "_chatgpt-translated/zh/2023-01-01-hello-zh.md" exists
    And File "_chatgpt-translated/zh/2023-01-01-hello-zh.md" contains "/2023-01-01-hello-chinese.html"
    And File "_chatgpt-translated/zh/2023-01-01-hello-zh.md" contains "translated-language: \"zh\""
    And File "_site/2023/01/01/hello.html" exists
    And File "_site/2023/01/01/hello.html" contains "The Chinese: /2023-01-01-hello-chinese.html"
    And File "_site/2023-01-01-hello-chinese.html" exists
    And File "_site/2023-01-01-hello-chinese.html" contains "The original: /2023/01/01/hello.html"
    And File "_site/2023/hello-french.html" exists
    And Exit code is zero

