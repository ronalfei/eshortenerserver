%% Feel free to use, reuse and abuse the code in this file.

-include("ess.hrl").
-module(ess_auth).

-compile(export_all).

-define(KEY, <<"lenovolabslenovodmt">>).

-define(EXPIRE_TIME, 600). %Key will be expired after ten minutes 

%% API.
exec(Time, Key) when is_binary(Time), is_binary(Key)->
	{T1, T2, _T3} = now(),
	Expire = T1 * 1000000 + T2 + ?EXPIRE_TIME,
	T = list_to_integer(binary_to_list(Time)),
	lager:debug("Expire Time : ~p, Now :~p", [Expire, T]),
	case Expire > T of 
		true ->
			Str = <<Time/binary, ?KEY/binary>>,
			Md5 = md5:string(Str),
			lager:debug("calc out md5: ~p ,pass key : ~p", [Md5, Key]),
			case list_to_binary(Md5) == Key of
				true	-> {true,	ok};
				false	-> {false,	<<"invalid tk">>}
			end;

		_	 -> {false, <<"expired">>}
	end.
	

