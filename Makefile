ZIG ?= zig
ARGS ?=

.PHONY: help build run test fmt clean

help:
	@echo "Targets:"
	@echo "  make build        Build and install to zig-out/"
	@echo "  make run          Run the app (use ARGS='...')"
	@echo "  make test         Run tests"
	@echo "  make fmt          Format Zig sources"
	@echo "  make clean        Remove build output"

build:
	$(ZIG) build

run:
	$(ZIG) build run -- $(ARGS)

test:
	$(ZIG) build test

fmt:
	$(ZIG) fmt src build.zig

clean:
	rm -rf .zig-cache zig-out
