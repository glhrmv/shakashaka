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
write_char(b) :- char_code(Char, 9632), write(Char).
write_char(ult) :- char_code(Char, 9705), write(Char).
write_char(urt) :- char_code(Char, 11028), write(Char).
write_char(llt) :- char_code(Char, 11029), write(Char).
write_char(lrt) :- char_code(Char, 9706), write(Char).
write_char(_) :- false.

