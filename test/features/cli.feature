Feature: Validate CLI configuration

    @Acceptance
    Scenario: Prints help correctly
        When the app runs with parameters "-h"
        Then the app exits without error
        And the app output contains "Usage:"

    @Acceptance
    Scenario: Prints version correctly
        When the app runs with parameters "version"
        Then the app exits without error
        And the app output contains "version: "
