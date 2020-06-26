DIST ?= fc31
VERSION := $(shell cat version)
REL := 2

FEDORA_SOURCES := https://src.fedoraproject.org/rpms/polybar/raw/f$(subst fc,,$(DIST))/f/sources

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

URLS ?= https://github.com/polybar/polybar/archive/$(VERSION)/polybar-$(VERSION).tar.gz \
	https://github.com/polybar/i3ipcpp/archive/21ce9060ac7c502225fdbd2f200b1cbdd8eca08d/i3ipcpp-21ce906.tar.gz \
	https://github.com/polybar/xpp/archive/f70dd8bb50944ab64ab902d9d8ab555599249dc1/xpp-f70dd8b.tar.gz

UNTRUSTED_SUFF := .UNTRUSTED
FETCH_CMD := wget --no-use-server-timestamps -q -O

SHELL := /bin/bash

%: %.sha512
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(filter %$@,$(URLS))
	@sha512sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

.PHONY: get-sources
get-sources: $(notdir $(URLS))

.PHONY: verify-sources
verify-sources:
	@true

# This target is generating content locally from upstream project
# 'sources' file. Sanitization is done but it is encouraged to perform
# update of component in non-sensitive environnements to prevent
# any possible local destructions due to shell rendering
.PHONY: update-sources
update-sources:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/generate-hashes-from-sources $(FEDORA_SOURCES)
