Feature: Landing on the Homepage

  As a shopaholic
  I want to navigate to Centric Shopping Store
  So I can start to shop

  @home_page @rspec_test @unit_test
  Scenario: Verify I should be able to land on the homepage
    Given I enter Centric Shopping Store URL (ph)
    Then I should see the home page (ph)
