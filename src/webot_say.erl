%% @author tobbe@klarna.com
%% @doc Say

-module(webot_say).
-export([init/1
         , allowed_methods/2
         , content_types_accepted/2
         , malformed_request/2
         , resource_exists/2
         , to_text/2]).

-ignore_xref([init/1
              , allowed_methods/2
              , content_types_accepted/2
              , malformed_request/2
              , resource_exists/2
              , to_text/2
              , ping/2
             ]).

-include_lib("webmachine/include/webmachine.hrl").

-define(EBOT_WORKER, ebot_webot).

-record(ctx, {
          method,
          channel,
          msg
         }).


init([]) ->
    {ok, #ctx{}}.
%  {{trace, "/tmp"}, #ct{}. % when debugging!


%%
allowed_methods(ReqData, State) ->
    {['PUT'], ReqData, State#ctx{method = wrq:method(ReqData)}}.


%%
content_types_accepted(ReqData, State) ->
      {[{"text/plain", to_text}], ReqData, State}.


%%
malformed_request(ReqData, #ctx{method = 'PUT'} = State) ->
    Channel = wrq:path_info(channel, ReqData),
    case wrq:req_body(ReqData) of
        undefined -> {true, ReqData, State};
        Msg ->
            {false, ReqData, State#ctx{channel = Channel, msg = Msg}}
    end.


%%
resource_exists(ReqData, #ctx{method = 'PUT'} = State) ->
    case whereis(?EBOT_WORKER) of
        Pid when is_pid(Pid) -> {true,  ReqData, State};
        _                    -> {false, ReqData, State}
    end.

%%
to_text(ReqData, #ctx{channel = Channel, msg = Msg} = State) ->
    ebot:say(?EBOT_WORKER, binary_to_list(Msg), "#"++Channel),
    {<<"ok">>, ReqData, State}.
