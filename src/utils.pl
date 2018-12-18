/* Utils */

get_value(Puz, RowN,ColN,TheChar) :-
  Row is RowN - 1,
  Col is ColN - 1,
  nth0(Row, Puz, RowList),
  nth0(Col, RowList, TheChar), !.

get_value(_, _, _, TheChar) :-
  TheChar is 0.

lists_concatenatedTails([],[]).
lists_concatenatedTails([Xs0|Xss],Ys) :-
  append(Xs0,Ys0,Ys),
  lists_concatenatedTails(Xss,Ys0).

% write_char(+Char)
write_char(e) :- write(' ').
write_char(0) :- write(0).
write_char(1) :- write(1).
write_char(2) :- write(2).
write_char(3) :- write(3).
write_char(4) :- write(4).
write_char(b) :- put_code(9632). %char_code(Char, 9632), write(Char).
write_char(ult) :- put_code(9705). %char_code(Char, 9705), write(Char).
write_char(urt) :- put_code(11028). %char_code(Char, 11028), write(Char).
write_char(llt) :- put_code(11029). %char_code(Char, 11029), write(Char).
write_char(lrt) :- put_code(9706). %char_code(Char, 9706), write(Char).
write_char(_) :- false.

convert_to_one_board([]        , []       , []       , []       , []       , []      , []    ) :- !.
convert_to_one_board([L1 | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [_ | L5s], [_ | Ps], [S|Ss]) :-
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
	

