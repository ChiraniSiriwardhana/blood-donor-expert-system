%% =====================================================================
%%  TEST CASES
%%  Expected vs actual results.  Run:  swipl -g run_tests -t halt tests/test_expert_system.pl
%% =====================================================================

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(yall)).

% when run on its own, load the knowledge base and the engine
:- if(\+ current_predicate(run_forward/0)).
:- include('../src/knowledge_base.pl').
:- include('../src/inference_engine.pl').
:- endif.

base([age-30, sex-male, first_time-no, months_since_last-12, weight_kg-70, haemoglobin-14,
      pregnant-no, serious_illness-no, epilepsy-no, risk_behaviour-no, valid_id-yes,
      travel_country-none, months_since_return-999]).

%% case(No, Description, Overrides, ExpectedStatus, ExpectedDeferrals)
case(1,  'Healthy repeat donor, no travel', [], eligible, []).
case(2,  'Healthy first-time donor, age 25', [first_time-yes, months_since_last-999, age-25], eligible, []).
case(3,  'Under-age donor (17)', [age-17], not_eligible, [underage]).
case(4,  'Donor older than 60 (62)', [age-62], not_eligible, [over_60]).
case(5,  'First-time donor aged 57', [first_time-yes, months_since_last-999, age-57], not_eligible, [first_time_over_55]).
case(6,  'Repeat donor aged 57', [age-57], eligible, []).
case(7,  'Donated only 2 months ago', [months_since_last-2], not_eligible, [interval]).
case(8,  'Underweight (48 kg) and low haemoglobin (11.8)', [sex-female, weight_kg-48, haemoglobin-11.8], not_eligible, [underweight, low_haemoglobin]).
case(9,  'Boundary: weight exactly 50 kg', [weight_kg-50], not_eligible, [underweight]).
case(10, 'Boundary: haemoglobin exactly 12.5', [haemoglobin-12.5], not_eligible, [low_haemoglobin]).
case(11, 'Pregnant donor', [sex-female, pregnant-yes], not_eligible, [pregnant]).
case(12, 'Serious medical illness', [serious_illness-yes], not_eligible, [serious_illness]).
case(13, 'History of epilepsy', [epilepsy-yes], not_eligible, [epilepsy]).
case(14, 'Risk behaviour reported', [risk_behaviour-yes], not_eligible, [risk_behaviour]).
case(15, 'Returned from India 12 months ago', [travel_country-'India', months_since_return-12], not_eligible, [malaria_travel]).
case(16, 'Returned from India 40 months ago', [travel_country-'India', months_since_return-40], eligible, []).
case(17, 'Non-endemic country trip, returned 1 month ago', [travel_country-other, months_since_return-1], not_eligible, [foreign_travel]).
case(18, 'Non-endemic country trip, returned 5 months ago', [travel_country-other, months_since_return-5], eligible, []).
case(19, 'Multiple reasons: age 17, pregnant, Kenya 6 months ago',
         [age-17, sex-female, pregnant-yes, travel_country-'Kenya', months_since_return-6],
         not_eligible, [malaria_travel, pregnant, underage]).
case(20, 'No valid ID available', [valid_id-no], not_eligible, [no_id]).
case(21, 'Unsure about travel status (refer to NBTS staff)', [travel_country-unsure], refer_nbts, []).

override(Base, Ov, R) :-
    findall(K-V, ( member(K-V0, Base), ( memberchk(K-V1, Ov) -> V = V1 ; V = V0 ) ), R).

%% run_case(+No, -Status, -Deferrals, -RulesFired)
run_case(N, Status, Defs, Fired) :-
    case(N, _, Ov, _, _), base(B), override(B, Ov, Inputs),
    clear_wm,
    forall(member(A-V, Inputs), assertz(known(A, V))),
    run_forward,
    known(status, Status),
    findall(D, known(deferral, D), Ds), msort(Ds, Defs),
    findall(Id, fired(Id), Fired).


%% ---------------------------------------------------------------------
%%  EXPLANATION TESTS (backward chaining / proof tree)
%%  For every case: (a) the backward-chaining proof of the expected status
%%  exists, (b) its root rule is the final-decision rule that fired in forward
%%  chaining, (c) the deferral/referral rules used in the proof are a subset of
%%  the d-rules that fired (the proof needs only ONE reason to prove s02, the
%%  forward-chaining trace lists ALL reasons); if no d-rule fired, the proof
%%  uses none, (d) a wrong status can NOT be proved.
%% ---------------------------------------------------------------------
proof_rules(p_leaf(_), []).
proof_rules(p_rule(Id, _, Subs), [Id|Rs]) :-
    maplist(proof_rules, Subs, Ls), append(Ls, Rs).

is_d_rule(Id) :- sub_atom(Id, 0, 1, _, d).
is_s_rule(Id) :- sub_atom(Id, 0, 1, _, s).

%% explain_case(+No, -Ok, -Info)
explain_case(N, Ok, info(Root, ProofDs, FiredDs, WrongBlocked)) :-
    case(N, _, _, ES, _),
    run_case(N, _, _, Fired),
    ( bc(status = ES, p_rule(Root, _, _) ) -> true ; Root = none ),
    ( bc(status = ES, Proof) -> proof_rules(Proof, Ids) ; Ids = [] ),
    include(is_d_rule, Ids, PDs0), sort(PDs0, ProofDs),
    include(is_d_rule, Fired, FDs0), sort(FDs0, FiredDs),
    include(is_s_rule, Fired, [FiredS|_]),
    member(Wrong, [eligible, not_eligible, refer_nbts]), Wrong \== ES, !,
    findall(W, ( member(W, [eligible, not_eligible, refer_nbts]), W \== ES, bc(status = W, _) ), Bad),
    ( Bad == [] -> WrongBlocked = yes ; WrongBlocked = no ),
    ( FiredDs == [] -> DsOk = ( ProofDs == [] ) ; DsOk = ( ProofDs \== [], subset(ProofDs, FiredDs) ) ),
    ( Root == FiredS, call(DsOk), WrongBlocked == yes -> Ok = pass ; Ok = fail ).

run_explain_tests :-
    findall(R, ( case(N, Desc, _, _, _),
                 ( explain_case(N, R, info(Root, PD, FD, WB)) -> true ; R = fail, Root=none, PD=[], FD=[], WB=no ),
                 format("[~w] Explanation test ~w: ~w~n     proof root: ~w | rules in proof: ~w | rules fired: ~w | wrong status blocked: ~w~n",
                        [R, N, Desc, Root, PD, FD, WB]) ), Rs),
    include(==(pass), Rs, Ps), length(Ps, P), length(Rs, T),
    format("~nExplanation tests: passed ~w of ~w.~n", [P, T]),
    ( P == T -> true ; halt(1) ).

%% run everything (status tests + explanation tests)
run_all_tests :- run_tests, run_explain_tests.

%% command-line test runner
run_tests :-
    findall(R, ( case(N, Desc, _, ES, ED),
                 run_case(N, AS, AD, Fired), msort(ED, EDs),
                 ( ( AS == ES, AD == EDs ) -> R = pass ; R = fail ),
                 format("[~w] Test ~w: ~w~n     expected: ~w ~w~n     actual  : ~w ~w~n     rules   : ~w~n",
                        [R, N, Desc, ES, ED, AS, AD, Fired]) ), Rs),
    include(==(pass), Rs, Ps), length(Ps, P), length(Rs, T),
    format("~nPassed ~w of ~w tests.~n", [P, T]),
    ( P == T -> true ; halt(1) ).
