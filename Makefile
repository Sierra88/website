#
# Make the BunsenLabs Website
# Written by 2ion <dev@2ion.de>
#

SHELL=/bin/bash

# Pandoc site template
TEMPLATE=templates/default.html5

# Determine HTML targets
TARGETS=$(patsubst %.mkd,%.html,$(wildcard src/*.mkd))

# Files to deploy
ASSETS=$(TARGETS) src/js src/img src/css src/robots.txt

# Main navigation and page header
NAVIGATION_HTML=src/include/navigation.html

# CSS include path, relative to pageroot
STYLE=css/plain.css

# Pandoc arguments
ARGV=--email-obfuscation=javascript \
		 --smart \
		 --template=$(TEMPLATE) \
		 -f markdown+footnotes+fenced_code_attributes \
		 -s \
		 -c $(STYLE) \
		 --highlight-style monochrome \
		 --include-before-body=$(NAVIGATION_HTML)

# Checkout directory which will be uploaded
DESTDIR=dst

# Page root
URL_PREFIX=https://fserve.2ion.eu/bunsen0

OPENGRAPH_IMG=img/opengraph-flame.png

# Provides page titles
include config/pagetitles.mk

### UTILITY TARGETS ###

.PHONY: rebuild checkout all clean deploy

rebuild: clean checkout

checkout: all
	@rsync -au --human-readable $(ASSETS) $(DESTDIR)

all: $(TARGETS) 

clean:
	rm -f src/*.html
	rm -fr dst/*

deploy: checkout
	$(info deploy: not implemented)

### PAGE BUILD TARGETS ###

%.html: %.mkd $(TEMPLATE)
	$(info -----)
	pandoc $(ARGV) \
		-M pagetitle="$($<.title)" \
		-M filename="$(@F)" \
		-M url-prefix="$(URL_PREFIX)" \
		-M opengraph-image="$(OPENGRAPH_IMG)" \
		-o $@ $<
	./postproc $@

# For the gitlog page, include a header with CSS/JS links and a footer
# to post-load the query JS code.
src/gitlog.html: src/gitlog.mkd $(TEMPLATE)
	$(info *****)
	pandoc $(ARGV) \
		-M pagetitle="$($<.title)" \
		-A src/include/gitlog_afterbody.html \
		-H src/include/gitlog_header.html \
		-o $@ $<
	./postproc $@

