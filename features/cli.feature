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
    The Chinese: {{ page.chatgpt-translate.urls['zh'] }}
    The French: {{ page.chatgpt-translate.urls['fr'] }}
    {{ content }}
    """
    And I have a "_layouts/chinese-translated.html" file with content:
    """
    Chinese: {{ content }}
    The original: {{ page.chatgpt-translate.original-url }}
    """
    And I have a "_layouts/translated.html" file with content:
    """
    French: {{ content }}
    The original: {{ page.chatgpt-translate.original-url }}
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
    And Exit code is zero
    And File "_chatgpt-translate/zh/2023-01-01-hello-zh.md" exists
    And File "_chatgpt-translate/zh/2023-01-01-hello-zh.md" contains "/2023-01-01-hello-chinese.html"
    And File "_chatgpt-translate/zh/2023-01-01-hello-zh.md" contains "language: \"zh\""
    And File "_site/2023/01/01/hello.html" exists
    And File "_site/2023/01/01/hello.html" contains "The Chinese: /2023-01-01-hello-chinese.html"
    And File "_site/2023-01-01-hello-chinese.html" exists
    And File "_site/2023-01-01-hello-chinese.html" contains "The original: /2023/01/01/hello.html"
    And File "_site/2023/hello-french.html" exists

  Scenario: Simple download of existing page
    Given I have a "_config.yml" file with content:
    """
    url: https://www.yegor256.com
    markdown: kramdown
    plugins:
      - jekyll-chatgpt-translate
    chatgpt-translate:
      source: en
      version: ""
      api_key: "it-is-not-used, because EN to EN translation"
      layout: should-not-be-used
      targets:
        -
          language: ru
          permalink: about-me.html
    """
    And I have a "_posts/2023-01-01-hello.md" file with content:
    """
    ---
    title: foo
    ---
    see translated page: {{ page.chatgpt-translate.urls['ru'] }}
    """
    Then I build Jekyll site
    And Exit code is zero
    And Stdout contains "No need to translate, the page exists"
    And File "_site/2023/01/01/hello.html" exists
    And File "_site/2023/01/01/hello.html" contains "see translated page: /about-me.html"
    And File "_site/about-me.html" exists
    And File "_site/about-me.html" contains "Yegor Bugayenko"

  Scenario: Simple download of existing page, but with re-translation
    Given I have a "_config.yml" file with content:
    """
    url: https://www.yegor256.com
    markdown: kramdown
    plugins:
      - jekyll-chatgpt-translate
    chatgpt-translate:
      source: en
      version: "my-own-version"
      api_key: "it-is-not-used, because EN to EN translation"
      layout: default
      targets:
        -
          language: en
          permalink: about-me.html
    """
    And I have a "boom.html" file with content:
    """
    Boom!
    """
    And I have a "_layouts/default.html" file with content:
    """
    {{ content }}
    """
    And I have a "_posts/2023-01-01-hello.md" file with content:
    """
    ---
    title: foo
    ---
    foo-file-foo
    """
    Then I build Jekyll site
    And Exit code is zero
    And Stdout contains "Re-translation required for"
    And File "_site/2023/01/01/hello.html" exists
    And File "_site/about-me.html" exists
    And File "_site/about-me.html" contains "foo-file-foo"
    And File "_site/boom.html" exists
