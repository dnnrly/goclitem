GO111MODULE=on

CURL_BIN ?= curl
GO_BIN ?= go
GORELEASER_BIN ?= goreleaser

PUBLISH_PARAM?=
GO_MOD_PARAM?=-mod vendor
TMP_DIR?=./tmp

BASE_DIR=$(shell pwd)

NAME=goclitem

export GO111MODULE=on
export GOPROXY=https://proxy.golang.org
export PATH := $(BASE_DIR)/bin:$(PATH)

help:   ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sort | sed -e 's/\\$$//' | sed -e 's/:.\+##/ --/'

.PHONY: install
install: ## install goclitem
	$(GO_BIN) install -v ./cmd/$(NAME)

.PHONY: build
build: ## build goclitem
	$(GO_BIN) build -v ./cmd/$(NAME)

.PHONY: clean
clean: ## remove build artifacts and release directories
	rm -f $(NAME)
	rm -rf dist/
	rm -rf cmd/$(NAME)/dist

.PHONY: clean-deps
clean-deps: ## remove dependency artifacts in the working director
	rm -rf ./bin
	rm -rf ./tmp
	rm -rf ./libexec
	rm -rf ./share

./bin/bats: ./bin ./tmp
	git clone https://github.com/bats-core/bats-core.git ./tmp/bats
	./tmp/bats/install.sh .

./bin/golangci-lint:
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.40.1

./bin/tparse: ./bin ./tmp
	curl -sfL -o ./tmp/tparse.tar.gz https://github.com/mfridman/tparse/releases/download/v0.7.4/tparse_0.8.3_Linux_x86_64.tar.gz
	tar -xf ./tmp/tparse.tar.gz -C ./bin

.PHONY: test-deps
test-deps: ./bin/tparse ./bin/bats ./bin/golangci
	$(GO_BIN) install github.com/mfridman/tparse
	$(GO_BIN) get -v ./...

./bin:
	mkdir ./bin

./tmp:
	mkdir ./tmp

./bin/goreleaser: ./bin ./tmp
	$(CURL_BIN) --fail -L -o ./tmp/goreleaser.tar.gz https://github.com/goreleaser/goreleaser/releases/download/v0.165.0/goreleaser_Linux_x86_64.tar.gz
	gunzip -f ./tmp/goreleaser.tar.gz
	tar -C ./bin -xvf ./tmp/goreleaser.tar

.PHONY: build-deps
build-deps: ./bin/goreleaser ## ci target - install build runtime dependencies

.PHONY: deps
deps: build-deps test-deps ## ci target - install all runtime dependencies

.PHONY: test
test: ## run unit tests and format for human consumption
	$(GO_BIN) test -json ./... | tparse -all

.PHONY: acceptance-test
acceptance-test: ## run acceptance tests against the build goclitem
	bats --tap test/*.bats

.PHONY: ci-test
ci-test: ## ci target - run tests to generate coverage data
	$(GO_BIN) test -race -coverprofile=coverage.txt -covermode=atomic ./...

.PHONY: lint
lint: ## run linting
	golangci-lint run

.PHONY: release
release: clean ## build release artifacts and upload to github
	cd cmd/$(NAME) ; $(GORELEASER_BIN) $(PUBLISH_PARAM)

.PHONY: update
update: ## update packages
	$(GO_BIN) get -u
	$(GO_BIN) mod tidy
	make test
	make install
	$(GO_BIN) mod tidy

