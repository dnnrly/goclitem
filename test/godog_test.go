package test_test

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/cucumber/godog"
	"github.com/cucumber/godog/colors"
	"github.com/spf13/pflag"
)

func TestMain(m *testing.M) {
	pflag.Parse()

	suite := godog.TestSuite{
		Name:                "API Acceptance Tests",
		ScenarioInitializer: InitializeScenario,
		Options: &godog.Options{
			Output: colors.Colored(os.Stdout),
			Format: "pretty",
		},
	}
	status := suite.Run()

	if st := m.Run(); st > status {
		status = st
	}

	os.Exit(status)
}

// nolint: unused
func InitializeTestSuite(ctx *godog.TestSuiteContext) {
	ctx.BeforeSuite(func() {})
}

// nolint: unused
func InitializeScenario(ctx *godog.ScenarioContext) {
	tc := testContext{}
	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		return ctx, nil
	})
	ctx.After(func(ctx context.Context, sc *godog.Scenario, err error) (context.Context, error) {
		if err != nil {
			fmt.Printf(
				"Command line output for \"%s\"\nUsing parameters: %s\n%s",
				sc.Name,
				tc.cmdInput.parameters,
				tc.cmdResult.Output,
			)
		}
		return ctx, nil
	})
	ctx.Step(`^the app runs without args$`, tc.theAppRunsWithoutArgs)
	ctx.Step(`^the app runs with parameters "(.*)"$`, tc.theAppRunsWithParameters)
	ctx.Step(`^the app exits without error$`, tc.theAppExitsWithoutError)
	ctx.Step(`^the app exits with an error$`, tc.theAppExitsWithAnError)
	ctx.Step(`^the app output contains "(.*)"$`, tc.theAppOutputContains)
	ctx.Step(`^the app output does not contain "(.*)"$`, tc.theAppOutputDoesNotContain)
	ctx.Step(`^a file "([^"]*)" exists$`, tc.aFileExists)
}
