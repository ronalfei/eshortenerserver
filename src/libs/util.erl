-module(util).
-export([ntop/1]).
ntop(N)->
        [{M, P, process_info(P, [registered_name, initial_call,current_function, dictionary]), B} ||
        {P, M, B} <- lists:sublist(lists:reverse(lists:keysort(2,processes_sorted_by_binary())),N)].


processes_sorted_by_binary()->
     [case process_info(P, binary) of
              {_, Bins} ->
                 SortedBins = lists:usort(Bins),
                 {_, Sizes, _} = lists:unzip3(SortedBins),
                 {P, lists:sum(Sizes), []};
              _ ->
                {P, 0, []}
         end ||P <- processes()].
