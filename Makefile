PREFIX:=../
DEST:=$(PREFIX)$(PROJECT)
ERL=erl
REBAR=./rebar3
GIT = git
REBAR_VER = 3.13.2
SESSION_CONFIG_DIR=priv/test_session_config

.PHONY: deps get-deps test dialyze clean edoc

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
	$(ERL) -pa ebin -pa ./_build/default/lib/*/ebin -run boss_doc run -noshell -s init stop
#$(ERL) -pa ebin -noshell -eval "boss_doc:run()" -s init stop

app:
	@(if ! echo "$(PROJECT)" | grep -qE '^[a-z]+[a-zA-Z0-9_@]*$$'; then echo "Project name should be a valid Erlang atom."; exit 1; fi)
	@$(REBAR) new skel dest=$(DEST) appid=$(PROJECT) skip_deps=true
	@echo ""
	@echo "***********************************************************************"
	@echo ""
	@echo "Your new app is created. You should head over there now:"
	@echo ""
	@echo "    cd $(DEST)"
	@echo ""
	@echo "***********************************************************************"
	@echo ""

get-deps:
	@$(REBAR) get-deps

deps:
	@$(REBAR) compile

dialyze: all
	@$(REBAR) dialyzer

clean:
	@$(REBAR) clean
	@rm -f src/boss/*.dtl.erl
	@rm -fv erl_crash.dump
	@rm -fv rebar3.crashdump
	@rm -fv rebar.lock

test:
	@$(REBAR) do eunit -c, ct -c, proper -c, cover -v

test_session_cache:
	$(ERL) -pa _build/default/lib/boss/ebin/ -run boss_session_test start -config $(SESSION_CONFIG_DIR)/cache -noshell

test_session_mnesia:
	$(ERL) -pa _build/default/lib/boss/ebin -run boss_session_test start -config $(SESSION_CONFIG_DIR)/mnesia -noshell

test_session_mock:
	$(ERL) -pa _build/default/lib/boss/ebin -run boss_session_test start -config $(SESSION_CONFIG_DIR)/mock -noshell
