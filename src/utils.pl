get_pos(Puz, Row,Col,TheChar) :-    
  nth(Row,Puz,RowList),
  nth(Col,RowList,TheChar).
