Feature: Cookies
  In order to read the page
  As a Licensing Authority
  I want to see accessibility statement page

  Scenario: User sees accessibility statement page
    Given I am on the Sign in page
    When I press Accessibility link
    Then I should see "Accessibility statement for Retrofitted Vehicles Upload Portal"
    And I should see "Reporting accessibility problems with this website"
