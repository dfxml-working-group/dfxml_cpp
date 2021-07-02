#!/usr/bin/make -f

# This software is a work of the Naval Postgraduate School (NPS) and the
# National Institute of Standards and Technology (NIST) . As a work of
# the US Government this work is not subject to copyright law. Neither
# NPS nor NIST assumes any responsibility whatsoever for its use by
# other parties, and makes no guarantees, expressed or implied, about
# its quality, reliability, or any other characteristic.

# Additionally, we waive copyright and related rights in the work worldwide
# through the CC0 1.0 Universal public domain dedication at https://creativecommons.org/publicdomain/zero/1.0/.
#
# Contributions by non-US government entities herein are covered under the LGPL
# which is in src/COPYING.md



SHELL ?= /bin/bash

SCHEMA_REPOSITORY_URL ?= https://github.com/dfxml-working-group/dfxml_schema.git

all:

.PHONY: schema-init

schema-init: schema/dfxml.xsd

schema/dfxml.xsd: dfxml_schema_commit.txt
	if [ -z "$(SCHEMA_REPOSITORY_URL)" ]; then echo 'ERROR:Makefile:Please provide a URL for the Makefile parameter SCHEMA_REPOSITORY_URL.' >&2 ; exit 1 ; fi
	if [ ! -d schema ]; then git clone $(SCHEMA_REPOSITORY_URL) schema ; cd schema ; git checkout $$(head -n1 ../dfxml_schema_commit.txt) ; fi
	test -r $@ && touch $@

clean:
	find . -name '*~' -exec rm {} \;

check:
	(cd src;make check)
	@echo performing checks currently in Travis
