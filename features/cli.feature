Feature: Simple site building
  I want to be able to build a site

  Scenario: Simple site
    Given I have a "_config.yml" file with content:
    """
    hello
    """
    When I build Jekyll site
    Then Stdout contains "done"
    And Exit code is zero

