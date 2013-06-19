
-compile([{parse_transform, lager_transform}]).

-define(LOG_LEVEL, debug). % log levle will be lager's levels [debug,info,notice,warning,error,critical,alert,emergency, none]

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


