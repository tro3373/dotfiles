SHELL := bash
PATH := $(PWD)/bin:$(PATH)
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := run

# Makefile覚書: Goアプリ開発に役立ちそうな基礎知識 | フューチャー技術ブログ https://future-architect.github.io/articles/20231012a/
dotenv := $(PWD)/.env
# -: means ignore error
-include $(dotenv)

name := $(shell grep module ./go.mod|head -1|sed -e 's,^.*/,,g')
depends_cmds := go gosec goreleaser #statik

export

tag:
	@v=$$(ver -n) && echo "==> New tag: $${v}" && git tag $${v}
tagp: tag
	@git push --tags

check:
	@for _cmd in ${depends_cmds}; do command -v $$_cmd >&/dev/null || (echo "No $$_cmd command" && exit 1); done
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

build-linux-arm: _build-linux-arm64
build-linux-amd: _build-linux-amd64
build-android-arm: _build-android-arm64
build-android-amd: _build-android-amd64
build-darwin-arm: _build-darwin-arm64
build-darwin-amd: _build-darwin-amd64
build-windows-arm: _build-windows-arm64
build-windows-amd: _build-windows-amd64
# CGO_ENABLED=0: Disable CGO
# -trimpath: Remove all file system paths from the resulting executable.
# -s: Omit the symbol table and debug information.
# -w: Omit the DWARF symbol table.
_build-%: check clean sec
	$(eval goos=$(firstword $(subst -, ,$*)))
	$(eval goarch=$(word 2, $(subst -, ,$*)))
	$(eval mainver=$(shell ver))
	@env GOOS=$(goos) GOARCH=$(goarch) CGO_ENABLED=0 \
		go build \
			-trimpath \
			-ldflags="-s -w -X main.version=$(mainver)" \
			-o $(name) \
			.

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
