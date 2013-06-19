-module(uuid).
-include("../ess.hrl").

-compile(export_all).

-define(KEY, <<"2*1#0^!0">>).
-define(CHARS, <<"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ">>).


create(Needle) ->
	create(Needle, 1).

create(Needle, From) when From > 0 , From =< 24 ->
	Md5 = md5:string(<<?KEY/binary, Needle/binary>>),

	lager:debug("md5 is ~p ~n", [Md5]),

	Int = list_to_integer(lists:sublist(Md5, From, 8), 16),

	SourceInt = Int band 1073741823, % 1073741823 = 0x3FFFFFFF

	lager:debug("SourceInt is ~p", [SourceInt]),

	IndexResult = countIndex(SourceInt, 5, 6, []),

	lager:debug("IndexResult is ~p", [IndexResult]),

	F = fun(X, R) ->
		Char = findChar(X),
		<<Char:1/binary, R/binary>>
	end,
	Hashes = lists:foldr(F, <<>>, IndexResult),
	Hashes.




findChar(0) ->
	<<"a">>;
findChar(1) ->
	<<"a">>;
findChar(Index) when Index < 63 , Index > 0 ->
	Length = Index-1,
	<<_H:Length/binary, Char:1/binary, _Tail/binary>> = ?CHARS,
	Char.
	

countIndex(_SourceInt, _BitShift, 0, Result) ->
	Result;
countIndex(SourceInt, BitShift, OperateCount, Result) ->
	Ret = SourceInt band 61,
	NewInt = SourceInt bsr BitShift,
	countIndex(NewInt, BitShift, OperateCount-1, [Ret|Result]).
	
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%class surl
%{
%    static private $key = '2#2&3!@#';
%    static private $chars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
%
%
%    /**
%     * 生成字串,参数是url,但其实带入任何一个字符串都可以的.
%     * Enter description here ...
%     * @param url $long_url
%     * @param num $num 取第几个返回值
%     * 
%     */
%    static public function create($long_url, $num=0)
%    {
%        $surl = Array();
%        $md5 = md5(self::$key.$long_url);
%        //echo $md5, " md5 \r\n";
%        for($i=0; $i<4; $i++)
%        {
%            $tmpstr = substr($md5, $i*8, 8);
%            // echo $tmpstr, " tmpstr \r\n";
%            $hexstr = base_convert($tmpstr,16,10) &  0x3FFFFFFF;
%            // echo $hexstr, "hex str \r\n";
%            $outchars = "";
%            for( $j=0; $j<6; $j++) {
%                $index = 0x0000003D & $hexstr ;
%                //echo $index, "index \r\n\r\n";
%                $outchars .= self::$chars{$index};
%                $hexstr = $hexstr >> 5;
%                //echo $hexstr, "after 5 \r\n";
%            }
%            $surl[] = $outchars;
%        }
%        if($num <= 0 ){
%            return $surl;
%        }else{
%            $n = $num-1;
%            return $surl[$n];
%        }
%
%    }
%
%}
%?>
