-module(ess_util).

-include("ess.hrl").
-include("records.hrl").

-compile(export_all).


response_json(Code, Msg, Data) ->
	Term = [
		{<<"code">>, Code},
		{<<"msg">>, Msg},
		{<<"data">>, Data}
	],
	lager:debug("jsx will encode Term : ~p ~n", [Term]),
	jsx:encode(Term).


hostname() ->
	{ok, HostName} = inet:gethostname(),
	list_to_binary(HostName).
