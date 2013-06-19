# Feel free to use, reuse and abuse the code in this file.

all: app

app: get-deps
	@./rebar compile
	ctags -R ./

get-deps:
	@./rebar get-deps

clean:
	@./rebar clean
	rm -f erl_crash.dump

dist-clean: clean
