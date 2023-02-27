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

#  @login @regression @test_case_54323 @test
#  Scenario: Manager Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @functional @test_case_54324 @test
#  Scenario: Admin Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @regression @test_case_54325 @test
#  Scenario: Engineer Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @smoke @test_case_54326 @test
#  Scenario: Architect Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @functional @test_case_54327 @test
#  Scenario: VP Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @smoke @test_case_54328 @test
#  Scenario: President Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @regression @test_case_54329 @test
#  Scenario: Leadership Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website
#
#  @login @smoke @test_case_54330 @test
#  Scenario: HR Login to Centric Store
#    Given I land on the shopping website homepage
#    When I login to the website