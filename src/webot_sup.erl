%% @author tobbe@tornkvist.org
%% @copyright 2011 tobbe@tornkvist.org
%% @doc Supervisor for the webot application.

-module(webot_sup).

-behaviour(supervisor).

%% External exports
-export([start_link/0, upgrade/0, get_config/0]).

%% supervisor callbacks
-export([init/1]).

-ignore_xref([start_link/0, upgrade/0, get_config/0, init/1]).

%% @spec start_link() -> ServerRet
%% @doc API for starting the supervisor.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% @spec init([]) -> SupervisorTree
%% @doc supervisor callback.
init([]) ->
    Ip = case os:getenv("WEBMACHINE_IP") of false -> "0.0.0.0"; Any -> Any end,
    {ok, Dispatch} = file:consult(filename:join(
                         [filename:dirname(code:which(?MODULE)),
                          "..", "priv", "dispatch.conf"])),
    WebConfig = [
                 {ip, Ip},
                 {port, 8000},
                 {log_dir, "priv/log"},
                 {dispatch, Dispatch}],
    Web = {webmachine_mochiweb,
           {webmachine_mochiweb, start, [WebConfig]},
           permanent, 5000, worker, dynamic},

    Ebots = [{list_to_atom(proplists:get_value(workername, Data)),
              {ebot, start_link, [Data]},
              permanent, 5000, worker, dynamic}
             || Data <- get_config()],

    Processes = [Web]++Ebots,

    {ok, { {one_for_one, 10, 10}, Processes} }.



%% First look in /etc then in our own priv dir.
get_config() ->
    case file:consult("/etc/webot.conf") of
        L when is_list(L) -> L;
        _ ->
            [_Beam,"ebin"|RevTokPath] = 
                lists:reverse(string:tokens(code:which(?MODULE),"/")),
            PrivPath = string:join(
                         lists:reverse(["priv"|RevTokPath]),"/"),
            {ok,L} = file:consult("/"++PrivPath++"/webot.conf"),
            L
    end.
