list_length(Size, List) :- length(List, Size).

not_longer_than([], []).
not_longer_than([], [_|_]).
not_longer_than([_|X], [_|Y]) :-
    not_longer_than(X, Y).

split_list(List, SubSize, SubLists) :-
    not_longer_than(SubLists, List),
    maplist(list_length(SubSize), SubLists),
    append(SubLists, List).

set_values_at_zero([]) :- !.

set_values_at_zero([X | Xs]) :-
	X is 0,
	set_values_at_zero(Xs).