-compile([{parse_transform, lager_transform}]).

-define(LOG_LEVEL, debug). % log levle will be lager's levels [debug,info,notice,warning,error,critical,alert,emergency, none]

-define(HTTP_PORT, 8181). % cowboy http listen port

-define(HTTP_DOMAIN, <<"dl.vips100.com">>). % cowboy http listen port


-define(MYSQL_HOST, "10.100.1.106").
-define(MYSQL_PORT, 3306).
-define(MYSQL_USER, "user").
-define(MYSQL_PASSWORD, "pass").
-define(MYSQL_DATABASE, "ld_ess").


-define(HOSTNAME, ess_util:hostname()).

-define(
ROUTER,
[ 
    {'_', [ 
         {"/new",			new,    	[]} 
        ,{"/check",			check,		[]} 
        ,{"/delete",        delete,		[]} 
        ,{'_',				index,		[]} 
    ]} 
]

).


