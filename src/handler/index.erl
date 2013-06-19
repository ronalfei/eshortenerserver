%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(index).

-include("../ess.hrl").
-include("../records.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
try
	%lager:debug("Original Req = ~n ~p ~n", [Req]),
	{Path , Req1} = cowboy_req:path(Req),
	Hash = fetch_hash(binary:split(Path, <<"/">>, [global])),
	case Hash of
		<<>> -> erlang:throw({400,<<"invalid url">>});
		_ -> ""
	end,
	Result = ess_dao:get(Hash, records),
	
	case Result of 
		[] ->
			{ok, Req2} = cowboy_req:reply(404, [], <<"no url found or url expired">>, Req1);

		[UrlInfo] ->
			Url		= UrlInfo#url_map.url,
			Host	= UrlInfo#url_map.host,
			Expire	= UrlInfo#url_map.expire,
			%calendar:datetime_to_gregorian_seconds(erlang:localtime()), % result is 63538020074 can use be compare
			case Host of
				<<>>	->
					{ok, Req2} = cowboy_req:reply(301, [{<<"Location">>, Url}], <<>>, Req1);
				undefined ->
					{ok, Req2} = cowboy_req:reply(301, [{<<"Location">>, Url}], <<>>, Req1);
				Host ->
					{ok, Req2} = cowboy_req:reply(200, [{<<"Content-Type">>, <<"text/html">>}], iframe(Url), Req1)
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


%---------------------------intenal function -------------------
fetch_hash([]) ->
	<<>>;
fetch_hash([H | PathListTail]) ->
	case H of
		<<>> -> fetch_hash(PathListTail);
		_ -> H
	end.


iframe(Url) ->
	<<"<html><head><title></title></head><body><iframe frameborder='no' border=0 width='100%' height='755px' src='", Url/binary, "'></iframe></body></html>">>.
