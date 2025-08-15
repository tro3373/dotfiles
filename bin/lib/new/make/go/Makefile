SHELL := bash
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(patsubst %/,%,$(dir $(mkfile_path)))
PATH := $(mkfile_dir)/bin:$(PATH)
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := build

dotenv := $(PWD)/.env
-include $(dotenv)

app := app
stage := dev

export

dst := /tmp/api

all: clean gen tidy fmt lint build test
clean:
	@echo "==> Cleaning" >&2
	@rm -f $(dst)
	@go clean -cache -testcache
tidy:
	@echo "==> Running go mod tidy -v"
	@go mod tidy -v
tidy-go:
	@v=$(shell go version|awk '{print $$3}' |sed -e 's,go\(.*\)\..*,\1,g') && go mod tidy -go=$${v}
deps:
	@go list -m all
update:
	@go get -u ./...
fmt:
	@echo "==> Running go fmt ./..." >&2
	@go fmt ./...
lint:
	@echo "==> Running golangci-lint run" >&2
	@golangci-lint run
build:
	@echo "==> Go Building" >&2
	@env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o $(dst) cmd/main.go
run:
	@air -c .air.toml


pkg := ./...
cover_mode := atomic
cover_out := cover.out
test: testsum-cover-check
# test-normal:
# 	@echo "==> Testing $(pkg)" >&2
# 	@go test -v $(pkg)
# test-cover:
# 	@echo "==> Running go test with coverage check" >&2
# 	@go test $(pkg) -coverprofile=$(cover_out) -covermode=$(cover_mode) -coverpkg=$(pkg)
# test-cover-count:
# 	@echo "==> Running go test with coverage check (count mode)" >&2
# 	@make test-cover cover_mode=count
# 	@go tool cover -func=$(cover_out)
# test-cover-html: test-cover
# 	@go tool cover -html=$(cover_out) -o cover.html
# test-cover-open: test-cover
# 	@go tool cover -html=$(cover_out)
# test-cover-check: test-cover-html
# 	@echo "==> Checking coverage threshold" >&2
# 	@go-test-coverage --config=./.testcoverage.yml
testsum:
	@echo "==> Running go testsum" >&2
	@gotestsum --format testname -- -v $(pkg) -coverprofile=$(cover_out) -covermode=$(cover_mode) -coverpkg=$(pkg)
testsum-cover-check: testsum
	@echo "==> Running test-coverage" >&2
	@go-test-coverage --config=./.testcoverage.yaml


gen: mockery swag
swag:
	@echo "==> Running swag init" >&2
	@swag init -g cmd/main.go -o swagger --parseInternal --parseDependency --parseDependencyLevel 1
mockery:
	@echo "==> Running mockery" >&2
	@mockery
