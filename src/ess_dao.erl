-module(ess_dao).

-include("ess.hrl").
-include("records.hrl").

-compile(export_all).


get(Hash) when is_binary(Hash) ->
	get(Hash, proplists).

get(Hash, proplists) ->
	%------------proplist return------
	{_,_,_,Result,_} = mysql_util:execute_prepare(get_by_hash, [Hash]),
	FieldInfo = [<<"hash_id">>, <<"url">>, <<"host">>, <<"expire">>, <<"memo">> ],
	FormatTimeFun = fun
		({datetime,{{Y1,M1,D1},{H1,I1,S1}}}) ->
			[Y,M,D,H,I,S] = [ list_to_binary(integer_to_list(X)) || X <- [Y1, M1, D1, H1, I1, S1]],
			<<Y/binary, "-", M/binary, "-", D/binary, " ", H/binary, ":", I/binary, ":", S/binary>>;
		(Any) -> 
			Any
	end,
	case Result of
		[] ->
			[];
		_ ->
			Field = [ FormatTimeFun(X) || X <- lists:nth(1, Result)],
			lists:zip(FieldInfo, Field)
	end;



get(Hash, records) ->
	Resource = mysql_util:execute_prepare(get_by_hash, [Hash]),
	Result = emysql_util:as_record(Resource, url_map, record_info(fields, url_map)),
	Result.

	

set(Hash, Url, Host, Expire, Memo) ->
	L = [Hash, Url, Host, Expire, Memo],
	mysql_util:execute_prepare(set_by_hash, L).
