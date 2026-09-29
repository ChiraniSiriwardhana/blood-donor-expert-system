%% =====================================================================
%%  INFERENCE ENGINE
%%  Working memory, forward chaining (stratified) and backward chaining.
%% =====================================================================

:- thread_local known/2.    % working memory : known(Attribute, Value)
:- thread_local fired/1.    % firing trace   : fired(RuleId)

%% =====================================================================
%%  PART 3 : INFERENCE ENGINE
%% =====================================================================

%% ---- evaluating one condition against working memory ----
holds(A = V)             :- !, known(A, X), X == V, !.
holds(exists(A))         :- !, known(A, _), !.
holds(absent(A))         :- !, \+ known(A, _).
holds(in_kb(A, P))       :- !, known(A, X), G =.. [P, X], call(G), !.
holds(C) :- C =.. [Op, A, N], memberchk(Op, [<, >, >=, =<]),
            known(A, X), number(X), call(Op, X, N), !.

all_hold(Conds) :- forall(member(C, Conds), holds(C)).

%% ---------------- FORWARD CHAINING (data-driven) ----------------
%% Strata run in order 1,2,3 so that negation (absent/exists) is only
%% evaluated after all facts it depends on have been derived.
%% Inside a stratum: repeat { find unfired rule whose conditions all hold,
%% fire it and add its conclusion } until no rule can fire (fixpoint).
run_forward :- forall(between(1, 3, S), run_stratum(S)).

run_stratum(S) :- ( fire_one(S) -> run_stratum(S) ; true ).

fire_one(S) :-
    rule(Id, S, Conds, A = V, _),
    \+ fired(Id),
    all_hold(Conds),
    ( known(A, V) -> true ; assertz(known(A, V)) ),
    assertz(fired(Id)).

%% ---------------- BACKWARD CHAINING (goal-driven) ----------------
%% bc(Goal, ProofTree): to prove Attr=Value, find a rule concluding it and
%% recursively prove every condition; leaves are user facts or KB facts.
bc(A = V, p_leaf(T)) :-
    attribute(A, _), !,
    known(A, X), X == V,
    format(string(T), "~w = ~w   (given by the user)", [A, V]).
bc(A = V, p_rule(Id, A = V, Subs)) :-
    rule(Id, _, Conds, A = V, _),
    bc_all(Conds, Subs).

bc_all([], []).
bc_all([C|Cs], [S|Ss]) :- bc_cond(C, S), bc_all(Cs, Ss).

bc_cond(exists(A), S) :- !,
    rule(Id, _, Conds, A = V, _),
    bc_all(Conds, Subs), !,
    S = p_rule(Id, A = V, Subs).
bc_cond(absent(A), p_leaf(T)) :- !,
    \+ ( rule(_, _, Conds, A = _, _), bc_all(Conds, _) ),
    format(string(T), "no rule could prove any '~w' (none of the deferral rules applies)", [A]).
bc_cond(A = V, S) :- !, bc(A = V, S).
bc_cond(in_kb(A, P), p_leaf(T)) :- !,
    known(A, X), G =.. [P, X], call(G),
    format(string(T), "~w is a KB fact: ~w(~w)", [A, P, X]).
bc_cond(C, p_leaf(T)) :-
    C =.. [Op, A, N], memberchk(Op, [<, >, >=, =<]),
    known(A, X), number(X), call(Op, X, N),
    format(string(T), "~w ~w ~w   (actual value: ~w)", [A, Op, N, X]).


%% =====================================================================
%%  PART 4 : INPUT HANDLING
%% =====================================================================

clear_wm :- retractall(known(_, _)), retractall(fired(_)).

