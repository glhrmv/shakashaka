/* Utils */

get_value(Puzzle, Row, Col, Char) :-
  nth1(Row, Puzzle, RowList),
  nth1(Col, RowList, Char), !.

get_value(_, _, _, Char) :-
  Char is 0.

flatten_list([], []).
flatten_list([Xs0 | Xss],Ys) :-
  append(Xs0, Ys0, Ys),
  flatten_list(Xss, Ys0).

% print_char(+Char)
print_char(e) :- write(' ').
print_char(0) :- write(0).
print_char(1) :- write(1).
print_char(2) :- write(2).
print_char(3) :- write(3).
print_char(4) :- write(4).
print_char(b) :- put_code(9632).
print_char(ult) :- put_code(9700).
print_char(urt) :- put_code(9701).
print_char(llt) :- put_code(9699).
print_char(lrt) :- put_code(9698).
print_char(_) :- false.

convert_to_one_board([]        , []       , []       , []       , []       , []      , []    ) :- !.
convert_to_one_board([L1 | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [_ | L5s], [_ | Ps], [S | Ss]) :-
  L1 = 1,
  S = 'ult',
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

convert_to_one_board([_  | L1s], [L2| L2s], [_ | L3s], [_ | L4s], [_ | L5s], [_ | Ps], [S|Ss]) :-
  L2 = 1,
  S = 'urt',
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

convert_to_one_board([_  | L1s], [_ | L2s], [L3| L3s], [_ | L4s], [_ | L5s], [_ | Ps], [S|Ss]) :-
  L3 = 1,
  S = 'llt',
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

convert_to_one_board([_  | L1s], [_ | L2s], [_ | L3s], [L4| L4s], [_ | L5s], [_ | Ps], [S|Ss]) :-
  L4 = 1,
  S = 'lrt',
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

convert_to_one_board([_  | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [L5| L5s], [_ | Ps], [S|Ss]) :-
  L5 = 1,
  S = 'e',
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

convert_to_one_board([_  | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [_ | L5s], [P | Ps], [P|Ss]) :-
  convert_to_one_board(L1s, L2s, L3s, L4s, L5s, Ps, Ss).

