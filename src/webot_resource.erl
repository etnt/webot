%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(webot_resource).
-export([init/1]).

-include_lib("webmachine/include/webmachine.hrl").

-record(ctx, {
          method
         }).

init([]) ->
    {ok, #ctx{}}.
%  {{trace, "/tmp"}, #ct{}. % when debugging!

