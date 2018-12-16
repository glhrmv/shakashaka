get_pos(Puz, Row,Col,TheChar) :-    
  nth0(Row,Puz,RowList),
  nth0(Col,RowList,TheChar).
  
lists_concatenatedTails([],[]).
lists_concatenatedTails([Xs0|Xss],Ys) :-
    append(Xs0,Ys0,Ys),
    lists_concatenatedTails(Xss,Ys0).
