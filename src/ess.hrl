
-compile([{parse_transform, lager_transform}]).

-define(LOG_LEVEL, debug). % log levle will be lager's levels [debug,info,notice,warning,error,critical,alert,emergency, none]

-define(HTTP_PORT, 8181). % cowboy http listen port

-define(HTTP_DOMAIN, <<"dl.vips100.com">>). % cowboy http listen port

-define(
ROUTER,
[ 
    {'_', [ 
         {"/new",			new,    	[]} 
        ,{"/check",			check,		[]} 
        ,{'_',				index,		[]} 
    ]} 
]

).


