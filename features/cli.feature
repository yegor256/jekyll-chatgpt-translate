Feature: Simple site building
  I want to be able to build a site

  Scenario: Simple site
    Given I have a "_config.yml" file with content:
    """
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
    And I have a "_layout/default.yml" file with content:
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
    When I build Jekyll site
    Then Stdout contains "done"
    And Exit code is zero

