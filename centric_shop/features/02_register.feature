Feature: Registration

  As a shopaholic
  I want to be able to register myself on the website
  So I can have my own presonal shopping space

  @register @automation @functional
  Scenario: Register yourself
    Given I land on the shopping website homepage
    When I register myself on the website
    Then I should be able to below registration successful text
    """
    Your registration completed
    """