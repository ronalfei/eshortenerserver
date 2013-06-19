%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(ess_app).
-include("ess.hrl").

-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->

	Dispatch = cowboy_router:compile( ?ROUTER ),
io:format("dispatch is ~p", [Dispatch]),

	{ok, _} = cowboy:start_http(http, 100, [{port, ?HTTP_PORT}], [
	%{ok, _} = cowboy:start_http(http, 100, [{port, 80}], [
		{env, [{dispatch, Dispatch}]}
	]),
	ess_sup:start_link().

stop(_State) ->
	ok.

