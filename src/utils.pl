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
