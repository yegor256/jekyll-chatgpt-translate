Feature: Simple site building
  I want to be able to build a site

  Scenario: Simple site
    Given I have a "_config.yml" file with content:
    """
    markdown: kramdown
    chatgpt-translate:
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
    """
    And I have a "_layouts/default.html" file with content:
    """
    {{ content }}
    """
    And I have a "_posts/2023-01-01-hello.md" file with content:
    """
    ---
    layout: default
    ---
    Hello, world!
    """
    Then I build Jekyll site
    Then File "_site/2023/01/01/hello.html" exists
    And I run bash with:
    """
    pwd
    ls -al
    tree
    """
    And Exit code is zero

