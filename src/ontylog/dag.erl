%%%-------------------------------------------------------------------
%%% File    : dag.erl
%%% Author  : Robert Dionne
%%%
%%% This file is part of Bitstore.
%%%
%%% Bitstore is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%%
%%% Bitstore is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with Bitstore.  If not, see <http://www.gnu.org/licenses/>.
%%%
%%% Created :  05 Dec 2009 by Robert Dionne <dionne@dionne-associates.com>
%%%
%%% bitstore, Copyright (C) 2009-2010   Dionne Associates, LLC.
%%%-------------------------------------------------------------------
-module(dag).
-author('dionne@dionne-associates.com').

%% API
-export([build_dag/0,
        dag_node/2]).

-import(triple_store, [all_triples/0]).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: 
%% Description:
%%--------------------------------------------------------------------
dag_node(Id, Dict) ->
    receive
        {add, ArrowId, TargetPid} ->
            case dict:find(ArrowId,Dict) of
                {ok, TargetList} ->
                    dict:store(ArrowId,[TargetPid] ++ TargetList,Dict);
                error -> dict:store(ArrowId,[TargetPid],Dict)
            end,
            dag_node(Id, Dict);
        {name, Pid} -> Pid ! Id,
                  dag_node(Id,Dict)
    end.

build_dag() ->
    Nodes = dict:new(),
    lists:map(fun({Source,Arrow,Target}) ->
                      SourcePid = find_or_create_pid(Source,Nodes),
                      TargetPid = find_or_create_pid(Target,Nodes),
                      SourcePid ! {add, Arrow, TargetPid},
                      SourcePid
              end, all_triples()).
                      

%%====================================================================
%% Internal functions
%%====================================================================
find_or_create_pid(Id,Nodes) ->
    case dict:find(Id,Nodes) of
        {ok, Pid} ->
            Pid;
        error -> spawn(?MODULE, dag_node, [Id, dict:new()])
    end.
    
