@register
Feature: Registration

  As a shopaholic
  I want to be able to register myself on the website
  So I can have my own personal shopping space

  @register @automation @functional @test_case_54321 @test
  Scenario: Register yourself
    Given I land on the shopping website homepage
    When I register myself on the website
    Then I should be able to below registration successful text
    """
    Your registration completed
    """

  @register @automation @functional @test_case_54331 @test
  Scenario: Register Header Validation
    Given I land on the shopping website homepage
    When I navigate to Register page
    Then I should see on the page
    """
    Registeration
    """

