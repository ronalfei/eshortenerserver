#!/bin/sh
NAME="ess"
screen -dmS $NAME
screen -S $NAME -X screen erl -name ess@10.100.1.83 -pa ebin -pa deps/*/ebin -s ess -s reloader \
 +K true \
 +A 128 \
 -env ERL_MAX_PORTS 64000 \
 -env ERL_FULLSWEEP_AFTER 0 \
 -smp enable \
 +zdbbl 32768 \
 -setcookie ess \
 -eval "io:format(\"* Eventsource: http://localhost:8181/~n~n~n\"). "
