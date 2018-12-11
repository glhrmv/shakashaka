/* Shakashaka */

:- use_module(library(clpfd)).

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
  read_term(Stream, H, []),
  (   H == end_of_file
  ->  List = []
  ;   List = [H|T],
      read_file(Stream, T)
  ).

% solve_puzzle(+Puzzle, -Solution)
solve_puzzle(Puzzle, Solution) :-
  true.

% display_solution(+Solution)
display_solution(Solution) :-
  true.

