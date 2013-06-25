%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(delete).

-include("../ess.hrl").
-include("../records.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
try
%%-------logic here--------------------
	{ok, Body, Req1} = cowboy_req:body_qs(Req),
    Url		= cowboy_util:body_qs_val(<<"url">>, Body),
	case Url of
		<<>> -> erlang:throw({400, <<"bad request">>});
		_	 -> ok
	end,
	Time	= cowboy_util:body_qs_val(<<"t">>, Body),
	Key		= cowboy_util:body_qs_val(<<"k">>, Body),
	case ess_auth:exec(Time, Key) of
		{false, Msg} -> erlang:throw({403, Msg});
		{true, _}  -> ok  %% nothing todo
	end,
	Hash	= uuid:create(Url),

    ess_dao:delete(Hash),
	Response = ess_util:response_json(200, <<"ok">>, []),
	lager:debug("Response is ~p ~n", [Response]),
	{ok, Req2} = cowboy_req:reply(200, [{<<"HIT">>, ?HOSTNAME}], Response, Req1),

	{ok, Req2, State}
%%---------------------------------------
catch 
	throw:{Code, Msgx} ->
		Response1 = ess_util:response_json(Code, Msgx, []),
		{ok, Reqx} = cowboy_req:reply(200, [{<<"HIT">>, ?HOSTNAME}], Response1, Req),
		{ok, Reqx, State};

	_Type:Why  -> {ok, Reqx} = cowboy_req:reply(500, [{<<"HIT">>, ?HOSTNAME}], [ Why], Req),
			{ok, Reqx, State}

end.

terminate(_Reason, _Req, _State) ->
	ok.


%---------------------------intenal function -------------------
