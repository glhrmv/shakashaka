/* Shakashaka */

:- use_module(library(clpfd)).
:- use_module(library(lists)).

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
  % example file: 'puzzles/puzzle1.txt'
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

% solve_puzzle(+Puzzle, -Solution)
solve_puzzle(Puzzle, Solution) :-
  length(Puzzle, X),
  Puzzle = [P| _],
  length(P, Y), %TODO: fazer verificacao do tamanho de todas as listas
  write(X), nl,
  write(Y), nl,
  TotalSize is X * Y,
  
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
  
  /* all different */
  make_sum_one(TempList1, TempList2, TempList3, TempList4, TempList5),
  
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

% display_solution(+Solution)
display_solution(Solution) :-
  true.

make_sum_one([], [], [], [], []) :- !.
make_sum_one([L1 | L1s], [L2 | L2s], [L3 | L3s], [L4 | L4s], [L5 | L5s]) :-
  Sum is 1,
  Sum #= L1 + L2 + L3 + L4 + L5,
  make_sum_one(L1s, L2s, L3s, L4s, L5s).
  
  
	

