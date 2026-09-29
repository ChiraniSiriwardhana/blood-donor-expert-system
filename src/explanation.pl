%% =====================================================================
%%  EXPLANATION FACILITY
%%  Explains how a conclusion was reached: rules applied and backward proof tree.
%% =====================================================================

print_proof(p_leaf(T), D) :- indent(D), format("[fact] ~w~n", [T]).
print_proof(p_rule(Id, A = V, Subs), D) :-
    rule(Id, _, _, _, Src),
    indent(D), format("GOAL ~w = ~w   <-- rule ~w  [source: ~w]~n", [A, V, Id, Src]),
    D1 is D + 1,
    forall(member(S, Subs), print_proof(S, D1)).

indent(D) :- N is D * 4, forall(between(1, N, _), write(' ')).

%% ---------------- EXPLANATION (forward chaining trace) ----------------
cond_text(exists(A), T) :- !,
    findall(V, known(A, V), Vs),
    format(string(T), "at least one '~w' was found: ~w", [A, Vs]).
cond_text(absent(A), T) :- !,
    format(string(T), "no '~w' was found", [A]).
cond_text(in_kb(A, P), T) :- !,
    known(A, X), format(string(T), "~w = ~w is in the KB list ~w", [A, X, P]).
cond_text(A = V, T) :- !,
    ( known(A, X) -> true ; X = '?' ),
    format(string(T), "~w = ~w   (actual: ~w)", [A, V, X]).
cond_text(C, T) :-
    C =.. [Op, A, N],
    ( known(A, X) -> true ; X = '?' ),
    format(string(T), "~w ~w ~w   (actual: ~w)", [A, Op, N, X]).

