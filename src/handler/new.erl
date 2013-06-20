%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-include("../ess.hrl").

-module(new).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
try
	lager:debug("Original Req = ~n ~p ~n", [Req]),
	{ok, Body, Req1} = cowboy_req:body_qs(Req),
	Url		= cowboy_util:body_qs_val(<<"url">>, Body),

	case Url of
		<<>> -> erlang:throw({400, <<"bad request">>});
		_	 -> ok
	end,

	Host	= cowboy_util:body_qs_val(<<"host">>, Body),
	Expire	= cowboy_util:body_qs_val(<<"expire">>, Body),
	Memo	= cowboy_util:body_qs_val(<<"memo">>, Body),
	Time	= cowboy_util:body_qs_val(<<"t">>, Body),
	Key		= cowboy_util:body_qs_val(<<"k">>, Body),

	case ess_auth:exec(Time, Key) of
		{false, Msg} -> erlang:throw({403, Msg});
		{true, _}  -> ok
	end,

	Hash	= uuid:create(Url),
	ess_dao:set(Hash, Url, Host, Expire, Memo),
	Link = case Host of
		<<>> -> <<"https://", ?HTTP_DOMAIN/binary, "/", Hash/binary>>;
		_Any -> <<"http://", Host/binary, "/", Hash/binary>>
	end,
	Response = ess_util:response_json(200, <<"ok">>, [{<<"link">>, Link}, {<<"host">>, Host}, {<<"url">>, Url}, {<<"expire">>, <<>>}, {<<"memo">>, Memo}]),
	lager:debug("Response is ~p ~n", [Response]),
	ResponHeader = [{<<"HIT">>, ess_util:hostname()}, {<<"Content-Type">>, <<"application/json">>}, {<<"Access-Control-Allow-Origin">>, <<"*">>}],
	{ok, Req2} = cowboy_req:reply(200, ResponHeader, [Response], Req1),
	{ok, Req2, State}
catch
	throw:{Code, Msgx} ->
		Response1 = ess_util:response_json(Code, Msgx, []),
		{ok, Reqx} = cowboy_req:reply(200, [], Response1, Req),
		{ok, Reqx, State};
	E1:E2  -> {ok, Reqx} = cowboy_req:reply(500, [], [E1,E2], Req),
			{ok, Reqx, State}
end.

terminate(_Reason, _Req, _State) ->
	ok.
