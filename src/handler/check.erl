%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(check).

-include("../ess.hrl").
-include("../records.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
try
	lager:debug("Original Req = ~n ~p ~n", [Req]),
	{ok, Body, Req1} = cowboy_req:body_qs(Req),
	Url = cowboy_util:body_qs_val(<<"url">>, Body),
	case Url of 
		<<>> ->
			erlang:throw({400, <<"url empty">>});
		_ -> ""
	end,
	%Host = cowboy_util:body_qs_val(<<"host">>, Body),
	%Expire = cowboy_util:body_qs_val(<<"expire">>, Body),
	%Memo = cowboy_util:body_qs_val(<<"memo">>, Body),

	Hash = uuid:create(Url),
	Result = ess_dao:get(Hash, records),

	lager:debug("result = ~n ~p hash =~p  ~n", [Result, Hash]),

	case Result of 
		[] ->
			Response = ess_util:response_json(<<"200">>, Hash, []),
			{ok, Req2} = cowboy_req:reply(200, [], Response, Req1);
		[UrlInfo] ->
			Url		= UrlInfo#url_map.url,
			Host	= UrlInfo#url_map.host,
			Expire	= UrlInfo#url_map.expire,
			Memo	= UrlInfo#url_map.memo,
			%calendar:datetime_to_gregorian_seconds(erlang:localtime()), % result is 63538020074 can use be compare
			case Host of
				undefined ->
					Response = ess_util:response_json(200, <<"">>, [{<<"host">>, <<>>}, {<<"url">>, Url}, {<<"expire">>, <<>>}, {<<"memo">>, Memo}]),
					{ok, Req2} = cowboy_req:reply(200, [], Response, Req1);
				Host ->
					Response = ess_util:response_json(200, <<"">>, [{<<"host">>, Host}, {<<"url">>, Url}, {<<"expire">>, <<>>}, {<<"memo">>, Memo}]),
					{ok, Req2} = cowboy_req:reply(200, [], Response, Req1)
			end
	end,
	{ok, Req2, State}
catch
	throw:{Code, Msg} ->
		Response1 = ess_util:response_json(Code, Msg, []),
		{ok, Reqx} = cowboy_req:reply(200, [], Response1, Req),
		{ok, Reqx, State};

	_:_  -> {ok, Reqx} = cowboy_req:reply(500, [], [], Req),
			{ok, Reqx, State}
end.


terminate(_Reason, _Req, _State) ->
	ok.


%response= {{code:200}, {data:[]}, {msg:}}
