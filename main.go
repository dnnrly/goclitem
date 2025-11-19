package main

import (
	"fmt"

	"github.com/dnnrly/gobail"
	"github.com/spf13/cobra"
)

var version string = "unknown"

func main() {
	rootCmd := newRootCmd()
	rootCmd.AddCommand(newVersionCmd())

	gobail.Run(rootCmd.Execute())
}

func newRootCmd() *cobra.Command {
	rootCmd := &cobra.Command{
		Use:   "goclitem",
		Short: "goclitem - a tool for simulating cloud workloads",
	}
	return rootCmd
}

func newVersionCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Prints the version",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("version: " + version)
		},
	}
}
