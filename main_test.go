package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCreatesRootCmd(t *testing.T) {
	rootCmd := newRootCmd()
	assert.NotNil(t, rootCmd)
}

func TestCreatesVersionCmd(t *testing.T) {
	versionCmd := newVersionCmd()
	assert.NotNil(t, versionCmd)

	versionCmd.Run(versionCmd, nil)
}
