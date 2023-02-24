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

  @login @smoke @test_case_54322 @test
  Scenario: Login to Centric Shopping Store
    Given I land on the shopping website homepage
    When I login to the website
