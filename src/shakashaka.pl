/* Shakashaka */

:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(system)).

:- ensure_loaded('list_create.pl').
:- ensure_loaded('utils.pl').

% shakashaka(+File)
shakashaka(File) :-
  get_puzzle_from_file(File, Puzzle),
  write(Puzzle), nl,
  solve_puzzle(Puzzle, Solution),
  display_solution(Solution).

% get_puzzle_from_file(+File, -Puzzle)
get_puzzle_from_file(File, Puzzle) :-
  % example file: 'puzzles/puzzle1'
  open(File, read, Stream),
  read_file(Stream, Puzzle),
  close(Stream).

% read_file(+Stream, -List)
read_file(Stream, List):-
  read_term(Stream, Line, []),
  (   Line == end_of_file
  ->  List = []
  ;   List = [Line|Lines],
    read_file(Stream, Lines)
  ).

% display_solution(+Solution)
display_solution([]).
display_solution([Line | Lines]) :-
  write('| '),
  display_line(Line),
  nl,
  display_solution(Lines).

% display_line(+Line)
display_line([]).
display_line([Char | Chars]) :-
  write_char(Char),
  write(' | '),
  display_line(Chars).

/*
[
Y Y
X[1,2]
X[2,3]
]
*/

% solve_puzzle(+Puzzle, -Solution)
solve_puzzle(Puzzle, Solution) :-
  length(Puzzle, X),
  Puzzle = [P| _],
  length(P, Y), % TODO: fazer verificacao do tamanho de todas as listas
  TotalSize is X * Y,
  lists_concatenatedTails(Puzzle, PuzzleList),

  /* starting variables */
  length(TempList1, TotalSize),
  split_list(TempList1, Y, TriangleNL),
  domain(TempList1, 0, 1),

  length(TempList2, TotalSize),
  split_list(TempList2, Y, TriangleNR),
  domain(TempList2, 0, 1),

  length(TempList3, TotalSize),
  split_list(TempList3, Y, TriangleSL),
  domain(TempList3, 0, 1),

  length(TempList4, TotalSize),
  split_list(TempList4, Y, TriangleSR),
  domain(TempList4, 0, 1),

  length(TempList5, TotalSize),
  split_list(TempList5, Y, Whites),
  domain(TempList5, 0, 1),

  /* Every empty position must be 1
  Black position must be 0 */
  make_sum_one(TempList1, TempList2, TempList3, TempList4, TempList5, PuzzleList),

  /* If there is numbers, make the adjacent sum equals that */
  make_sum_equals_puzzle(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Puzzle, X, Y, X, Y),

  /* generating variables */
  labeling([], TempList1),
  labeling([], TempList2),
  labeling([], TempList3),
  labeling([], TempList4),
  labeling([], TempList5),

  write(TriangleNL), nl,
  write(TriangleNR), nl,
  write(TriangleSL), nl,
  write(TriangleSR), nl,
  write(Whites), nl,

  true.

make_sum_one([], [], [], [], [], []) :- !.
make_sum_one([L1 | L1s], [L2 | L2s], [L3 | L3s], [L4 | L4s], [L5 | L5s], [P | Ps]) :-
  P = 'e',
  Sum is 1,
  Sum #= L1 + L2 + L3 + L4 + L5, !,
  make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps).

make_sum_one([L1 | L1s], [L2 | L2s], [L3 | L3s], [L4 | L4s], [L5 | L5s], [P | Ps]) :-
  P = 'b',
  Sum is 0,
  Sum #= L1 + L2 + L3 + L4 + L5, !,
  make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps).

make_sum_one([_ | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [_ | L5s], [_ | Ps]) :-
  make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps).

make_sum_equals_puzzle( _,  _,  _,  _, _, 0, _,    _,    _) :- !.
make_sum_equals_puzzle(L1, L2, L3, L4, P, X, Y, XMax, YMax) :-
  XNew is X - 1,
  make_sum_equals_puzzle_r(L1, L2, L3, L4, P, X, Y, XMax, YMax),
  make_sum_equals_puzzle(L1, L2, L3, L4, P, XNew, Y, XMax, YMax).

make_sum_equals_puzzle_r( _,  _,  _,  _, _, _, 0,    _,    _) :- !.
make_sum_equals_puzzle_r(L1, L2, L3, L4, P, X, Y, XMax, YMax) :-
  YNew is Y - 1,
  get_value(P, X, Y, R),
  R \= 'b',
  R \= 'e',

  %up position
  XUP is X - 1,
  get_value(L1, XUP, Y, R1UP),
  get_value(L2, XUP, Y, R2UP),
  get_value(L3, XUP, Y, R3UP),
  get_value(L4, XUP, Y, R4UP),

  %left
  YL is Y - 1,
  get_value(L1, X, YL, R1L),
  get_value(L2, X, YL, R2L),
  get_value(L3, X, YL, R3L),
  get_value(L4, X, YL, R4L),

  %down
  XD is X + 1,
  get_value(L1, XD, Y, R1D),
  get_value(L2, XD, Y, R2D),
  get_value(L3, XD, Y, R3D),
  get_value(L4, XD, Y, R4D),

  %right
  YR is Y + 1,
  get_value(L1, X, YR, R1R),
  get_value(L2, X, YR, R2R),
  get_value(L3, X, YR, R3R),
  get_value(L4, X, YR, R4R),

  R #= R1UP + R2UP + R3UP + R4UP + R1L + R2L + R3L + R4L
  + R1D + R2D + R3D + R4D + R1R + R2R + R3R + R4R , !,
  make_sum_equals_puzzle_r(L1, L2, L3, L4, P, X, YNew, XMax, YMax).

make_sum_equals_puzzle_r(L1, L2, L3, L4, P, X, Y, XMax, YMax) :-
  YNew is Y - 1,
  make_sum_equals_puzzle_r(L1, L2, L3, L4, P, X, YNew, XMax, YMax).

