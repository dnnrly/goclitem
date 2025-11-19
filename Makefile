# vi:syntax=make

.ONESHELL:
.DEFAULT_GOAL := help
SHELL := /bin/bash
.SHELLFLAGS = -ec

TMP_DIR?=./tmp
TEST_TMP_DIR?=./test/tmp
BASE_DIR=$(shell pwd)
MAKEFILE_ABSPATH := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_RELPATH := $(call MAKEFILE_ABSPATH)

export GO111MODULE=on
export GOPROXY=https://proxy.golang.org
export PATH := $(BASE_DIR)/bin:$(PATH)

NAME := goclitem

TEST_PACKAGES := $(shell go list ./... | grep -v test)

.PHONY: help
help: ## print help message
	@echo "Usage: make <command>"
	@echo
	@echo "Available commands are:"
	@grep -E '^\S[^:]*:.*?## .*$$' $(MAKEFILE_RELPATH) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-4s\033[36m%-30s\033[0m %s\n", "", $$1, $$2}'
	@echo

.PHONY: clean
clean:
	@echo "Cleaning up"
	rm -rfv $(TMP_DIR) $(TEST_TMP_DIR)
	rm -vf $(NAME) coverage.txt coverage-merged.txt

.PHONY: generate
generate: ## generate mocks and other assets
	rm -fv mock_*.go
	go generate -x ./...

.PHONY: build
build: ## build the application
	go build -o $(NAME)

.PHONY: lint
lint: ## run linting with golangci-lint
	golangci-lint run

.PHONY: test
test: ## run unit tests with tparse
	go test -run COMPILE_ONLY > /dev/null # This will only print an output if there are compilation errors
	go test -race -cover -count=1 -json $(TEST_PACKAGES) | tparse -all

.PHONY: ci-test
ci-test: ## ci target - run tests to generate coverage data
	rm -rf ./tmp/coverage/ci-test.txt
	mkdir -p ./tmp/coverage
	go test -coverprofile=./tmp/coverage/ci-test.txt -covermode=set $(TEST_PACKAGES)


.PHONY: acceptance-test
acceptance-test: build ## run acceptance tests
	rm -rf ./test/tmp
	go build -cover -o $(NAME)
	mkdir -p ./test/tmp/coverage
	cd test && GOCOVERDIR=tmp/coverage go test -timeout 20s -tags acceptance
	
.PHONY: coverage-report
coverage-report: ## collate the coverage data
	mkdir -p tmp/coverage
	go tool covdata textfmt -i=test/tmp/coverage -o ./tmp/coverage/acceptance.txt

