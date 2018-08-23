TEST_CMD ?= busted -v
KONG_PATH ?=./kong
PLUGIN_NAME := kong-plugin-okta-auth

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))
SRC_PATH := $(current_dir)
DEV_PACKAGE_PATH := $(current_dir)lua_modules/share/lua/5.1/?

define set_env
	@eval $$(luarocks path); \
	LUA_PATH="$(DEV_PACKAGE_PATH).lua;$(SRC_PATH)spec/fixtures/?.lua;$$LUA_PATH" LUA_CPATH="$(DEV_PACKAGE_PATH).so;$$LUA_CPATH"; \
	cd $(KONG_PATH);
endef

install:
	luarocks make $(PLUGIN_NAME)-*.rockspec

uninstall:
	luarocks remove $(PLUGIN_NAME)-*.rockspec

install-dev:
	luarocks make --tree lua_modules $(PLUGIN_NAME)-*.rockspec

test: install-dev
	$(call set_env) \
	$(TEST_CMD) $(current_dir)spec/unit

build:
	docker-compose build apigw

integration-test:
	docker-compose run -w /integration apigw rspec

clean:
	@echo "removing $(PLUGIN_NAME)"
	-@luarocks remove --tree lua_modules $(PLUGIN_NAME)-*.rockspec >/dev/null 2>&1 ||:
