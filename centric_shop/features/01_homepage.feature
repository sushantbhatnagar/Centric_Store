Feature: Landing on the Homepage

  As a shopaholic
  I want to navigate to Centric Shopping Store
  So I can start to shop

  @home_page
  Scenario: Verify I should be able to land on the homepage
    Given I enter Centric Shopping Store URL
    Then I should see the home page
