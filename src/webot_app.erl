%% @author tobbe@tornkvist.org
%% @copyright 2011 tobbe@tornkvist.org

%% @doc Callbacks for the webot application.

-module(webot_app).

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for webot.
start(_Type, _StartArgs) ->
    application:start(inets),
    application:start(crypto),
    application:start(webmachine),
    webot_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for webot.
stop(_State) ->
    webot_sup:stop(),
    application:stop(webmachine),
    application:stop(crypto),
    application:stop(inets),
    ok.
