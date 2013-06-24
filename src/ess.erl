%% Feel free to use, reuse and abuse the code in this file.

-include("ess.hrl").
-module(ess).

%% API.
-export([start/0, log/1]).

%% API.

start() ->
	ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowboy),
	ok = application:start(lager),
	ok = application:start(emysql),
	ok = application:start(ess),
	mysql_util:init(),
	lager:set_loglevel(lager_console_backend, ?LOG_LEVEL).



log(Level) when is_atom(Level) ->
    lager:set_loglevel(lager_console_backend, Level).
