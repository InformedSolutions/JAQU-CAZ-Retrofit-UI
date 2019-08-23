Feature: Sign In
  In order to read the page
  As a Licensing Authority
  I want to see the upload page

  Scenario: View upload page without cookie
    Given I have no authentication cookie
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"
      And I should see "National Register of Retrofitted Vehicles" title
      And I should not see "Upload" link
      And I should not see "Data rules" link
    Then I should enter valid credentials and press the Continue
    When I should see "Retrofitted Vehicles Data Upload"
      And Cookie is created for my session

  Scenario: View upload page with cookie that has not expired
    Given I have authentication cookie that has not expired
    When I navigate to a Upload page
    Then I am redirected to the Upload page
      And I should see "Retrofitted Vehicles Data Upload"
      And I should see "Upload" link
      And I should see "Data rules" link

  Scenario: View upload page with cookie that has expired
    Given I have authentication cookie that has expired
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"

  Scenario: Sign in with invalid credentials
    Given I am on the Sign in page
    When I enter invalid credentials
    Then I remain on the current page
      And I should see "The email or password you entered is incorrect"

  Scenario: Sign out
    Given I am signed in
    When I request to sign out
    Then I am redirected to the Sign in page
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"

  Scenario: Sign in with invalid email format
    Given I am on the Sign in page
    When I enter invalid email format
    Then I remain on the current page
      And I should see "The email is in an invalid format"

  Scenario: Sign in with too long email address
    Given I am on the Sign in page
    When I enter too long email address
    Then I remain on the current page
      And I should see "The email exceeds the limit of 45 characters"
