%% Feel free to use, reuse and abuse the code in this file.

-include("ess.hrl").
-module(ess_auth).

-compile(export_all).

-define(KEY, <<"lenovolabslenovodmt">>).

-define(EXPIRE_TIME, 600). %Key will be expired after ten minutes 

%% API.
exec(Time, Key) when is_binary(Time), is_binary(Key)->
	{T1, T2, _T3} = now(),
	Now = T1 * 1000000 + T2,
	T = list_to_integer(binary_to_list(Time)),
    Expire = T + ?EXPIRE_TIME,
	lager:debug("~n Now time : ~p ~n Expire Time : ~p ~n Pass time :~p ~n", [Now, Expire, T]),
	case Now < Expire of 
		true ->
			Str = <<Time/binary, ?KEY/binary>>,
			Md5 = md5:string(Str),
			lager:debug("calc out md5: ~p ,pass key : ~p", [Md5, Key]),
			case list_to_binary(Md5) == Key of
				true	-> {true,	ok};
				false	-> {false,	<<"invalid tk">>}
			end;

		%_	 -> {false, <<"expired">>}
		_	 -> {true, <<"expired">>}
	end.
	

