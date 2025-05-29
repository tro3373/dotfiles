SHELL := bash
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(patsubst %/,%,$(dir $(mkfile_path)))
PATH := $(mkfile_dir)/bin:$(PATH)
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := run

tag := example:latest

build:
	@docker build -t $(tag) .

run:
	@docker run --rm -it \
		-v .:/app \
		-p 8080:8080 \
		$(tag)
