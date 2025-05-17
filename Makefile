# Copyright (C) 2025 Toit contributors
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

SPEC_GIT := https://github.com/mustache/spec.git
SPEC_PATH := tests/spec
EXE_EXT := $(if $(filter Windows_NT,$(OS)),.exe,)

.PHONY: all
all: build/mustache$(EXE_EXT)

build:
	@mkdir -p build

# TODO(floitsch): use the dependency file.
build/mustache$(EXE_EXT): install-pkgs bin/mustache.toit build
	@toit compile bin/mustache.toit -o build/mustache$(EXE_EXT)

.PHONY: install-pkgs
install-pkgs:
	@toit pkg install
	@toit pkg install --project-root=bin
	@toit pkg install --project-root=tests

.PHONY: test
test: $(SPEC_PATH) install-pkgs
	@toit tests/spec-test.toit $(SPEC_PATH)/specs

$(SPEC_PATH):
	@git clone $(SPEC_GIT) $(SPEC_PATH)
