SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := run

# Makefile覚書: Goアプリ開発に役立ちそうな基礎知識 | フューチャー技術ブログ https://future-architect.github.io/articles/20231012a/
DOTENV := $(PWD)/.env
# -: means ignore error
-include $(DOTENV)

name := $(shell grep module ./go.mod|head -1|sed -e 's,^.*/,,g')
depends_cmds := go gosec goreleaser #statik

export

tag:
	@v=$$(git tag --list |sort -V |tail -1) && nv="$${v%.*}.$$(($${v##*.}+1))" && echo "==> New tag: $${nv}" && git tag $${nv}
tagp: tag
	@git push --tags

check:
	@for cmd in ${depends_cmds}; do command -v $$cmd >&/dev/null || (echo "No $$cmd command" && exit 1); done
	@echo "[OK] check ok!"

clean:
	@for d in $(name); do if [[ -e $${d} ]]; then echo "==> Removing $${d}.." && rm -rf $${d}; fi done
	@echo "[OK] clean ok!"

run: check clean
	@go run .

test:
	@go test -v ./...

sec:
	@gosec --color=false ./...
	@echo "[OK] Go security check was completed!"

build: build-linux
build-linux:
	@make GOOS=linux GOARCH=amd64 _build
build-mac:
	@make GOOS=darwin GOARCH=arm64 _build
build-windows:
	@make GOOS=windows GOARCH=amd64 _build
build-android:
	@make GOOS=android GOARCH=arm64 _build
_build: check clean sec
	@env GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags="-s -w"

deps:
	@go list -m all

update:
	@go get -u ./...

tidy:
	@go mod tidy

tidy-go:
	@ver=$(shell go version|awk '{print $$3}' |sed -e 's,go\(.*\)\..*,\1,g') && go mod tidy -go=$${ver}

gr_init:
	@goreleaser init
gr_check:
	@goreleaser check
gr_snap:
	@goreleaser release --snapshot --clean $(OPT)
gr_snap_skip_publish:
	@OPT=--skip-publish make gr_snap
gr_build:
	@goreleaser build --snapshot --clean
