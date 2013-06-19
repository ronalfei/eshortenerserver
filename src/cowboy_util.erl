-module(cowboy_util).
-include("ess.hrl").

-compile(export_all).

body_qs_val(Key, Body) when is_binary(Key), is_list(Body) ->
	proplists:get_value(Key, Body, <<>>);

body_qs_val(_Key, _) -> <<>>.



parse_form_new(Req) ->
	parse_form_new(Req, <<>>).

parse_form_new(Req, Tail) -> 
	Form = case cowboy_req:multipart_data(Req) of
        {headers, [{_HName, HValue}], Req1} ->
            lager:debug("Header : ~p ~n", [HValue]),
            [HValue, parse_form_new(Req1)];
        {headers, [{_HName, HValue}, {_, _Type}], Req1} ->
            lager:debug("Header and Type  : ~p and  ~p~n", [HValue, _Type]),
            [HValue, parse_form_new(Req1)];
        {body, Body, Req1} ->
			NewBody = <<Tail/binary, Body/binary>>,
            lager:debug("body  : ~p ~n", [Body]),
            lager:debug("new body  : ~p ~n", [NewBody]),
            [ parse_form_new(Req1, NewBody)];
        {end_of_part, Req1} ->
            lager:debug("end of part"),
            [Tail, parse_form_new(Req1)];
        {eof, Req1}->
            lager:debug("eof"),
            [<<"req">>,Req1]
    end,
    lists:flatten(Form).

%parse_form_to_props([H1, H2 | []]) ->
%	[{H1,H2}];

parse_form_to_props([H1, H2 , <<"req">>|_T]) ->
	[{H1,H2}];

parse_form_to_props([H1, H2 | TForm]) ->
	[{H1,H2}|parse_form_to_props(TForm)].

get_res_tmp_path(PropForm) ->
	Pf = lists:flatten(PropForm),
	proplists:get_value(<<"form-data; name=\"file.path\"">>, Pf).

get_res_md5(PropForm) ->
	Pf = lists:flatten(PropForm),
	proplists:get_value(<<"form-data; name=\"file.md5\"">>, Pf).

%%-----------get range for upload block-----------
%% @doc return {Start, End}
get_range(Req) ->
	{RawRange, Req} = case cowboy_req:header('Range', Req, undefined) of
		{ undefined, Req } -> cowboy_req:header(<<"X-Lenovo-Range">>, Req, undefined);
		Raw -> Raw
	end,
	lager:debug("raw range header is ~p", [RawRange]),
	case RawRange of
		undefined ->
			{error, "no range found"};
		<<"bytes=", Rest/binary >> -> 
			lager:debug("range tokens -----------------------: ~p", [string:tokens(util:binary_to_list(Rest), "- ,")]),
			[Start, End | _Tail ]= string:tokens(util:binary_to_list(Rest), "- ,"),
			{ util:list_to_integer(Start), util:list_to_integer(End) }
	end.



%%this is only for cowboy's multipart form parse fields
%% @doc return proplist
%% @doc Req is cowboy's req
%parse_form(Boundary, Req) ->
%	ParserFun = cowboy_multipart:parser(Boundary),
%	Buffer = cowboy_req:get_buffer(Req),
%	lager:debug("~n~n bbbbbuuuuuuuuuuffffffffffffer:~p ~n~n", [Buffer]),
%	Form = case ParserFun(Buffer) of
%		{headers, [{_Cd, <<"form-data; name=\"", RestName/binary>>}|_], Fun} ->
%			lager:debug("1111111111 ~p ", [Fun]),
%			[RestName, parser(Fun)];
%		{body, Data, Fun} ->
%			lager:debug("dataaaaaaa : ~p ~n", [Data]),
%			[Data, parser(Fun)];
%		{more, Fun} -> 
%			lager:debug("moreeeeeeeeeeeee: ~p", [Fun]),
%			[Fun(Buffer)];
%        _Any->
%			lager:debug("anyyyyyyyy: ~p ~n", [_Any]),
%			[]
%	end,
%	lists:flatten(Form).
%
%
%parser(Fun) ->
%	case Fun() of
%		{headers, [{_Cd, <<"form-data; name=\"", RestName/binary>>}|_], Fun1 } ->
%			lager:debug("22222222222rest name ~p", [RestName]),
%			[RestName, parser(Fun1)];
%		{body, Data, Fun1 } -> 
%			lager:debug("33333333333333333 body ~p", [Data]),
%			[Data, parser(Fun1)];
%		{end_of_part, Fun1 } -> 
%			lager:debug("44444444444444444 body ~p", [Fun1]),
%			[parser(Fun1)];
%		{more, Fun1} -> 
%			lager:debug("55555555555555555 more ~p", [Fun1]),
%			[];
%		_Any -> 
%			lager:debug("22222222222222222anyyyyyyyy: ~p ~n", [_Any]),
%			[]
%	end.


