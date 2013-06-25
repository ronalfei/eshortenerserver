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
    check_ets(),
    EtsResource = ets:lookup(hashtable, Hash),
    lager:debug("Ets result is ~p", [EtsResource]),
    case EtsResource of
        [{Hash, EtsResult}] ->
            EtsResult;
        [] ->
	        Resource = mysql_util:execute_prepare(get_by_hash, [Hash]),
	        Result = emysql_util:as_record(Resource, url_map, record_info(fields, url_map)),
            lager:debug("mysql result is ~p", [Result]),
            case Result of 
                [] -> [];
                 _ ->
                    ets:insert(hashtable, {Hash, Result}),
	                Result
            end
    end.

	

set(Hash, Url, Host, Expire, Memo) ->
    lager:debug("passed expire time is ~p", [Expire]),
    ExpireTime = case Expire of
        <<>> ->
                {Y, M, D} = date(),
                Y1 = Y+1,
                Y_=list_to_binary(integer_to_list(Y1)), 
                M_=list_to_binary(integer_to_list(M)), 
                D_=list_to_binary(integer_to_list(D)), 
                lager:debug("Y ~p, M ~p, D ~p ", [Y_, M_, D_]),
                E = <<Y_/binary, "-", M_/binary, "-", D_/binary>>,
                lager:debug("expire time default is ~p ~n", [E]),
                E;
        _    -> Expire
    end,
	L = [Hash, Url, Host, ExpireTime, Memo],
	mysql_util:execute_prepare(set_by_hash, L).


delete(Hash) ->
    ets:delete(hashtable, Hash),
    mysql_util:execute_prepare(del_by_hash, [Hash]).


%%------------- ets intenal function------------
init_ets() ->
    Name = hashtable,
    Options = [set, public, named_table, {read_concurrency, true} ],
    ets:new(Name, Options),
    Leader = group_leader(),
    lager:debug(" group leader for this connnection is ~p", [Leader]),
    ets:give_away(hashtable, Leader, []).


check_ets() ->
    case ets:info(hashtable) of
        undefined ->
            init_ets();
        _ -> ok
    end.
