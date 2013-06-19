-module(mysql_util).
-include("ess.hrl").

-compile(export_all).

-define(POOL_NAME, ld_ess).


init() ->
    emysql:add_pool(?POOL_NAME, 10,
        "web", "147852369", "10.100.1.106", 3306,
        "ld_ess", utf8),
	emysql:prepare(get_by_hash, <<"select * from url_map where hash_id=?">>),
	emysql:prepare(set_by_hash, <<"replace into url_map set hash_id=?, url=?, host=?, expire=?, memo=?">>),
	lager:info("emysql pool init success").



select(Sql) when is_binary(Sql) ->
	Resource = emysql:execute(?POOL_NAME, Sql),
	lager:debug("mysql resource is ~p", [Resource]),
	Resource.

execute(Sql) when is_binary(Sql) ->
	emysql:execute(?POOL_NAME, Sql).

execute_prepare(Statment, Args) when is_list(Args), is_atom(Statment) ->
	emysql:execute(?POOL_NAME, Statment, Args).
