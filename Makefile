PREFIX:=../
DEST:=$(PREFIX)$(PROJECT)
ERL=erl
REBAR=./rebar
GIT = git
REBAR_VER = 2.6.1
SESSION_CONFIG_DIR=priv/test_session_config

.PHONY: deps get-deps test

all: compile

compile:
	@$(REBAR) get-deps
	@$(REBAR) compile
	@echo ""
	@echo "*********************************************************************************"
	@echo ""
	@echo "CONGRATULATIONS! You've successfully built ChicagoBoss. Pat yourself on the back."
	@echo ""
	@echo "If you're unsure what to do next, try making a new app with:"
	@echo ""
	@echo "    make app PROJECT=my_project_name"
	@echo ""
	@echo "*********************************************************************************"
	@echo ""

boss:
	@$(REBAR) compile skip_deps=true

edoc:
	$(ERL) -pa ebin -pa deps/*/ebin -run boss_doc run -noshell -s init stop
#$(ERL) -pa ebin -noshell -eval "boss_doc:run()" -s init stop

app:
	@(if ! echo "$(PROJECT)" | grep -qE '^[a-z]+[a-zA-Z0-9_@]*$$'; then echo "Project name should be a valid Erlang atom."; exit 1; fi)
	@$(REBAR) create template=skel dest=$(DEST) appid=$(PROJECT) skip_deps=true
	@mkdir -p $(DEST)/deps
	@cp -Rn $(PWD) $(DEST)/deps/boss
	@mv -n $(DEST)/deps/boss/deps/* $(DEST)/deps/
	@echo ""
	@echo "***********************************************************************"
	@echo ""
	@echo "Your new app is created. You should head over there now:"
	@echo ""
	@echo "    cd $(DEST)"
	@echo ""
	@echo "***********************************************************************"
	@echo ""

rebar_src:
	@rm -rf $(PWD)/rebar_src
	@$(GIT) clone git://github.com/rebar/rebar.git rebar_src
	@$(GIT) -C rebar_src checkout tags/$(REBAR_VER)
	@cd $(PWD)/rebar_src/; ./bootstrap
	@cp $(PWD)/rebar_src/rebar $(PWD)
	@cp $(PWD)/rebar_src/rebar $(PWD)/skel
	@rm -rf $(PWD)/rebar_src

get-deps:
	@$(REBAR) get-deps

deps:
	@$(REBAR) compile

## dialyzer
PLT_FILE = ~/chicagoboss.plt
PLT_APPS ?= kernel stdlib erts compiler runtime_tools syntax_tools crypto \
		mnesia ssl public_key eunit xmerl inets asn1 hipe edoc deps/*/ebin
DIALYZER_OPTS ?= -Werror_handling -Wrace_conditions -Wunmatched_returns \
		-Wunderspecs --verbose --fullpath -n

.PHONY: dialyze
dialyze: all
	@[ -f $(PLT_FILE) ] || $(MAKE) plt
	@dialyzer --plt $(PLT_FILE) $(DIALYZER_OPTS) ebin || [ $$? -eq 2 ];

## In case you are missing a plt file for dialyzer,
## you can run/adapt this command
.PHONY: plt
plt:
	@echo "Building PLT, may take a few minutes"
	@dialyzer --build_plt --output_plt $(PLT_FILE) --apps \
		$(PLT_APPS) || [ $$? -eq 2 ];

clean:
	@$(REBAR) clean
	@rm -f src/boss/*.dtl.erl
	rm -fv erl_crash.dump
	rm -f $(PLT_FILE)

test:
	@$(REBAR) skip_deps=true eunit

test_session_cache:
	$(ERL) -pa ebin -run boss_session_test start -config $(SESSION_CONFIG_DIR)/cache -noshell

test_session_mnesia:
	$(ERL) -pa ebin -run boss_session_test start -config $(SESSION_CONFIG_DIR)/mnesia -noshell

test_session_mock:
	$(ERL) -pa ebin -run boss_session_test start -config $(SESSION_CONFIG_DIR)/mock -noshell

