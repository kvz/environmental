# TODO: fix makefile to correspond the real situation
# (e.g. remove outdated targets and macros)

.PHONY: js test

COFFEE     = node_modules/.bin/coffee
COFFEELINT = node_modules/.bin/coffeelint
MOCHA      = node_modules/.bin/mocha --compilers coffee:coffee-script --require "coffee-script/register"
REPORTER   = nyan

test:
	$(MOCHA) --reporter $(REPORTER) test/

lint:
	@[ ! -f coffeelint.json ] && $(COFFEELINT) --makeconfig > coffeelint.json || true
	$(COFFEELINT) --file ./coffeelint.json src

build: lint
	$(COFFEE) $(CSOPTS) -c -o lib src/environmental.coffee

release: build test
	npm version patch -m "Upgrade to %s"
	git push
	npm publish

compile:
	@echo "Compiling files"
	time make build

watch:
	watch -n 2 make -s compile
