/* Shakashaka */

:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(system)).

:- ensure_loaded('list_create.pl').
:- ensure_loaded('utils.pl').

% shakashaka(+File)
shakashaka(File) :-
  % Get an input puzzle from the given file
  get_puzzle_from_file(File, Puzzle),
  write('Validating puzzle...'), nl,
  % Validate the puzzle
  (
    validate_puzzle(Puzzle) ->
    write('The puzzle is valid. Solving...'), nl
  ;
    write('The puzzle is not valid. Exiting...'), nl,
    false
  ),
  % Solve the puzzle
  (
    solve_puzzle(Puzzle, Solution, TimeElapsed) ->
    % Print out the original input puzzle
    write('Puzzle given:'), nl,
    print_puzzle(Puzzle),
    % Print out the solution to the puzzle
    write('Solution:'), nl,
    print_puzzle(Solution),
    % Get & print elapsed time
    write('Solving this puzzle took '), write(TimeElapsed), write(' ms.'), nl,
    true
  ;
    write('The puzzle is not solvable. Exiting...'), nl,
    false
  ).

% get_puzzle_from_file(+File, -Puzzle)
get_puzzle_from_file(File, Puzzle) :-
  % example file: 'puzzles/puzzle1'
  open(File, read, Stream),
  read_file(Stream, Puzzle),
  close(Stream).

% read_file(+Stream, -List)
read_file(Stream, List):-
  % Read stream until EOF,
  % adding each line
  % as an element onto List
  read_term(Stream, Line, []),
  (   Line == end_of_file
  ->  List = []
  ;   List = [Line|Lines],
    read_file(Stream, Lines)
  ).

% validate_puzzle(+Puzzle)
validate_puzzle(Puzzle) :-
  % If puzzle is of valid dimensions m x n
  validate_dimensions(Puzzle),
  % If puzzle has only accepted characters
  validate_lines(Puzzle).

% validate_dimensions(+Puzzle)
validate_dimensions(Puzzle) :-
  % Check if all of the sublists (puzzle rows)
  % have the same length (number of columns)
  equal_lengths(Puzzle).

% equal_lengths(+ListOfLists)
equal_lengths([]).
equal_lengths([[]]).
equal_lengths([[_ | _]]).
equal_lengths([X, Y | Rest]) :-
  length(X, Len),
  length(Y, Len),
  equal_lengths([Y | Rest]).

% validate_lines(+Puzzle)
validate_lines([]).
validate_lines([Line | Lines]) :-
  validate_line(Line),
  validate_lines(Lines).

% validate_line(+Line)
validate_line([]).
validate_line([Char | Chars]) :-
  % Input puzzle can only have these characters
  member(Char, [e, b, 0, 1, 2, 3, 4]),
  validate_line(Chars).

% print_puzzle(+Puzzle)
print_puzzle([]) :- !.
print_puzzle([Line | Lines]) :-
  put_code(9474),
  print_line(Line),
  nl,
  print_puzzle(Lines).

% print_line(+Line)
print_line([]) :- !.
print_line([Char | Chars]) :-
  print_char(Char),
  put_code(9474),
  print_line(Chars).

% solve_puzzle(+Puzzle, -Solution, -TimeElapsed)
solve_puzzle(Puzzle, Solution, TimeElapsed) :-
	% Start timer
	fd_statistics,
	statistics(walltime, [_TimeSinceStart | [_TimeSinceLastCall]]),
	statistics(memory, _),
	% Define domains
	length(Puzzle, X),
	Puzzle = [P| _],
	length(P, Y), % TODO: fazer verificacao do tamanho de todas as listas
	TotalSize is X * Y,
	flatten_list(Puzzle, PuzzleList),

	/*
	* Starting variables
	* */
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

	/*
	* Every empty position must be 1
	* Black position must be 0
	* */
	make_sum_one(TempList1, TempList2, TempList3, TempList4, TempList5, PuzzleList, Count),
	write('ESPACOS BRANCOS:  '),write(Count),nl,

	/* If there is numbers, make the adjacent sum equals that */
	make_sum_equals_puzzle(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, Puzzle, X, Y, X, Y),
	
	append(TempList1, TempList2, NewList1),
	append(NewList1, TempList3, NewList2),
	append(NewList2, TempList4, NewList3),
	append(NewList3, TempList5, FINAL),
	
	/* generating variables */
	%labeling([leftmost, down], FINAL),
	%labeling([leftmost], FINAL),
	%labeling([ff], FINAL),
	labeling([down], FINAL),
	%labeling([ffc], FINAL),

	%solve_puzzle([[e,e],[e,e]],S,L).
	fd_statistics(resumptions, Stats1),
	fd_statistics(entailments, Stats2),
	fd_statistics(prunings, Stats3),
	fd_statistics(backtracks, Stats4),
	fd_statistics(constraints, Stats5),
	write('Resumptions: '), write(Stats1), nl,
	write('entailments: '),write(Stats2), nl,
	write('prunings: '),write(Stats3), nl,
	write('backtracks: '),write(Stats4), nl,
	write('constraints: '),write(Stats5), nl,
	statistics(walltime, [_NewTimeSinceStart | [TimeElapsed]]),
	statistics,
	convert_to_one_board(TempList1, TempList2, TempList3, TempList4, TempList5, PuzzleList, SolutionNotFlat),
	split_list(SolutionNotFlat, Y, Solution).

	

make_sum_one([], [], [], [], [], [], 0) :- !.
make_sum_one([L1 | L1s], [L2 | L2s], [L3 | L3s], [L4 | L4s], [L5 | L5s], [P | Ps], Count) :-
	P = 'e', !,
	Sum is 1,
	Sum #= L1 + L2 + L3 + L4 + L5,
	make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps, CountN),
	Count is CountN + 1.

make_sum_one([L1 | L1s], [L2 | L2s], [L3 | L3s], [L4 | L4s], [L5 | L5s], [P | Ps], Count) :-
	P = 'b', !,
	Sum is 0,
	Sum #= L1 + L2 + L3 + L4 + L5,
	make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps, Count).

make_sum_one([_ | L1s], [_ | L2s], [_ | L3s], [_ | L4s], [_ | L5s], [_ | Ps], Count) :-
	make_sum_one(L1s, L2s, L3s, L4s, L5s, Ps, Count).

make_sum_equals_puzzle( _,  _,  _,  _,  _, _, 0, _,    _,    _) :- !.
make_sum_equals_puzzle(L1, L2, L3, L4, L5, P, X, Y, XMax, YMax) :- 
	XNew is X - 1,
	make_sum_equals_puzzle_r(L1, L2, L3, L4, L5, P,    X, Y, XMax, YMax),
	make_sum_equals_puzzle(  L1, L2, L3, L4, L5, P, XNew, Y, XMax, YMax).

make_sum_equals_puzzle_r(         _,          _,          _,          _,      _, _, _, 0,    _,    _) :- !.
make_sum_equals_puzzle_r(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, Y, XMax, YMax) :-
	YNew is Y - 1,
	get_value(P, X, Y, R),
	R \= 'e', !,

	get_value(TriangleNL, X, Y, R1),
	get_value(TriangleNR, X, Y, R2),
	get_value(TriangleSL, X, Y, R3),
	get_value(TriangleSR, X, Y, R4),
	get_value(Whites    , X, Y, R5),

	sum([R1, R2, R3, R4, R5], #=, 0),

	%up position
	XUP is X - 1,
	get_value(TriangleNL, XUP, Y, R1UP),
	get_value(TriangleNR, XUP, Y, R2UP),
	get_value(TriangleSL, XUP, Y, R3UP),
	get_value(TriangleSR, XUP, Y, R4UP),

	/* Constraint B */
	/* Borders of the puzzle must form 90 degrees */
	/* Also Black Blocks also must form 90 degrees */
	(   XUP > 0	->
	sum([R1UP, R2UP], #=, 0)
	; true %out of bounderies
	),

	%left
	YL is Y - 1,
	get_value(TriangleNL, X, YL, R1L),
	get_value(TriangleNR, X, YL, R2L),
	get_value(TriangleSL, X, YL, R3L),
	get_value(TriangleSR, X, YL, R4L),
	(   YL > 0	->
	  sum([R1L, R3L], #=, 0)
	; true %out of bounderies
	),

	%down
	XD is X + 1,
	get_value(TriangleNL, XD, Y, R1D),
	get_value(TriangleNR, XD, Y, R2D),
	get_value(TriangleSL, XD, Y, R3D),
	get_value(TriangleSR, XD, Y, R4D),
	(   XD < XMax	->
	  sum([R3D, R4D], #=, 0)
	; true %out of bounderies
	),

	%right
	YR is Y + 1,
	get_value(TriangleNL, X, YR, R1R),
	get_value(TriangleNR, X, YR, R2R),
	get_value(TriangleSL, X, YR, R3R),
	get_value(TriangleSR, X, YR, R4R),
	(   YR < YMax	->
	  sum([R2R, R4R], #=, 0)
	; true %out of bounderies
	),

	(
	  R \= 'b' ->
	  R #= R3UP + R4UP + R2L + R4L + R1D + R2D + R1R + R3R,
	  sum([R1UP, R2UP, R3D, R4D, R1L, R3L, R2R, R4R], #=, 0)
	;
	  true
	),

	/* END OF CONSTRAINT B */

	make_sum_equals_puzzle_r(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, YNew, XMax, YMax).

  % quando as casas estao vazias, comecando a trabalhar na restricao que o triangulo pode ter um seguinte igual em i+1 j+1 ou fechado ao lado
make_sum_equals_puzzle_r(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, Y, XMax, YMax) :-
	YNew is Y - 1,
    get_value(P, X, Y, R),
    R == 'e', !,%confirmacao que e so em espacos brancos
	
	/* Last Part of Constraint B but now for the empty spaces */
    %if they are in borders they can't make 45 degrees
    get_value(TriangleNL, X, Y, R1),
    get_value(TriangleNR, X, Y, R2),
    get_value(TriangleSL, X, Y, R3),
    get_value(TriangleSR, X, Y, R4),
	
    (X == 1 ->    sum([R3, R4], #=, 0);true),
    (Y == 1 ->    sum([R2, R4], #=, 0);true),
    (Y == YMax -> sum([R1, R3], #=, 0);true),
    (X == XMax -> sum([R1, R2], #=, 0);true),
	
	
	/* End of coinstraint B */
		%right
		YR is Y + 1,
		%down
		XD is X + 1,
		%left
		YL is Y - 1,
		%up position
		XUP is X - 1,

		/*
		STUPID ATTEMPT
		%prevent nested rectangles
		get_value(TriangleSR, X , Y , Nested1),
		get_value(TriangleSL, X , YR, Nested2),
		get_value(TriangleNR, XD, Y , Nested3),
		get_value(TriangleNL, XD, YR, Nested4),
		sum([Nested1, Nested2, Nested3, Nested4], #<, 4),
		*/
		%stop repeated triangles
		%DiffX is XMax - X,
		%DiffY is YMax - Y,
		
		/* EVITAR NESTED TRIANGLES!!!!! */
		get_value(TriangleNL, XD, YR, Nested1),
		sum([R1, Nested1], #<, 2),
		
		
		
		%stop_repeat_triangles(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, Y, XMax, YMax, DiffX, DiffY),
		/* CONSTRAINT D */
		/* There is always white spaces that form a rectangle, 
		   If there is 3 white spaces, they must end with a certain triangle depending of the direction 
		* */
            %making sure white spaces forms squares
			%w stands for white
            get_value(Whites	, X , Y , W1),
            get_value(Whites	, XD, Y , W2),
            get_value(Whites    , X , YR, W3),
            get_value(Whites    , XD, YR, W4),
            %SR position
            get_value(TriangleSR, XD, YR, SR),
            W1 + W2 + W3 #=< W4 + SR + 2,
            %SL Position
            get_value(TriangleSL, XD, Y , SL),
            W1 + W3 + W4 #=< W2 + SL + 2,
            %NR Position
            get_value(TriangleNR, X , YR, NR),
            W1 + W2 + W4 #=< W3 + NR + 2,
            %NL Position
            get_value(TriangleNL, X , Y , NL),
            W2 + W3 + W4 #=< W1 + NL + 2,

            get_value(Whites	, XUP, Y , WW2),
            get_value(Whites    , X  , YL, WW3),
            get_value(Whites    , XUP, YL, WW4),

            get_value(TriangleNL, XUP, YL, SR1),
            W1 + WW2 + WW3 #=< WW4 + SR1 + 2,
            %SL Position
            get_value(TriangleNR, XUP, Y , SL1),
            W1 + WW3 + WW4 #=< WW2 + SL1 + 2,
            %NR Position
            get_value(TriangleSL, X , YL, NR1),
            W1 + WW2 + WW4 #=< WW3 + NR1 + 2,
            %NL Position
            get_value(TriangleSR, X , Y , NL1),
            WW2 + WW3 + WW4 #=< W1 + NL1 + 2,
		
		/* END OF CONSTRAINT D */
		
		/* CONSTRAINT C */
		/* If there is a certain triangle, in the same diagonal 
			must have the same triangle (180degrees forming a line)
			or there must have a triangle that form 90 degrees */
		/* Otherwise, if there is a triangle that forms a line, 
			in the place that was possible to have a 90 
			degrees triangle must have a white space */
            %NL triangles (R1)
            %down direction
            get_value(TriangleNL, XD, YL, NLD1),
            get_value(TriangleSL, XD, Y , NLD2),
            R1 #=< NLD1 + NLD2,
            %up direction
            get_value(TriangleNL, XUP, YR, NLU1),
            get_value(TriangleNR, X  , YR, NLU2),
            R1 #=< NLU1 + NLU2,
            %down direction
            get_value(Whites, XD, Y, NLDW),
            R1 + NLD1 #=< NLDW + 1,
            %updirection
            get_value(Whites, X, YR, NLUW),
            R1 + NLU1 #=< NLUW + 1,

            %NR triangles (R2)
            %down direction
            get_value(TriangleNR, XD, YR, NRD1),
            get_value(TriangleSR, XD, Y, NRD2),
            R2 #=< NRD1 + NRD2,
            %up direction
            get_value(TriangleNR, XUP, YL, NRU1),
            get_value(TriangleNL, X, YL, NRU2),
            R2 #=< NRU1 + NRU2,
            %down direction
            get_value(Whites, XD, Y, NRDW),
            R2 + NRD1 #=< NRDW + 1,
            %updirection
            get_value(Whites, X, YL, NRUW),
            R2 + NRU1 #=< NRUW + 1,

            %SL triangles (R3)
            %down direction
            get_value(TriangleSL, XD, YR, SLD1),
            get_value(TriangleSR, X, YR, SLD2),
            R3 #=< SLD1 + SLD2,
            %up direction
            get_value(TriangleSL, XUP, YL, SLU1),
            get_value(TriangleNL, XUP, Y, SLU2),
            R3 #=< SLU1 + SLU2,
            %making white spaces to form bigger squares
            %down direction
            get_value(Whites, X, YR, SLDW),
            R3 + SLD1 #=< SLDW + 1,
            %updirection
            get_value(Whites, XUP, Y, SLUW),
            R3 + SLU1 #=< SLUW + 1,

            %SR triangles (R4)
            %down direction
            get_value(TriangleSR, XD, YL, SRD1),
            get_value(TriangleSL, X , YL, SRD2),
            R4 #=< SRD1 + SRD2,
            %up direction
            get_value(TriangleSR, XUP, YR, SRU1),
            get_value(TriangleNR, XUP, Y, SRU2),
            R4 #=< SRU1 + SRU2,
            %down direction
            get_value(Whites, X, YL, SRDW),
            R4 + SRD1 #=< SRDW + 1,
            %updirection
            get_value(Whites, XUP, Y, SRUW),
            R4 + SRU1 #=< SRUW + 1,
			
		/* END OF CONSTRAINT C */

		make_sum_equals_puzzle_r(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, YNew, XMax, YMax).
	/* Constraint E */
	/* Don't allow nested triangles */
	stop_repeat_triangles(_, _, _, _, _, _, _, _, _, _, 1, _) :- !.
	stop_repeat_triangles(_, _, _, _, _, _, _, _, _, _, _, 1) :- !.
	stop_repeat_triangles(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, Y, XMax, YMax, _, _) :-
		DiffX is XMax - X,
		DiffX > 1,
		DiffY is YMax - Y,
		DiffY > 1, !,
		get_value(TriangleNL, X, Y, Value1),
		XFinal is X + DiffX,
		YFinal is Y + DiffY,
		get_value(TriangleNL, XFinal, YFinal, Value2),

		sum_between_triangles(TriangleSR, X, Y, DiffX, DiffY, Sum),

		Value1 + Value2 #=< Sum + 1,
		NewXMax is XMax - 1,
		NewYMax is YMax - 1,
		stop_repeat_triangles(TriangleNL, TriangleNR, TriangleSL, TriangleSR, Whites, P, X, Y, NewXMax, NewYMax, DiffX, DiffY).
	stop_repeat_triangles(_, _, _, _, _, _, _, _, _, _, _, _) :- true.

	sum_between_triangles(_			, _, _,     _,     1, 0) :- !.
	sum_between_triangles(_			, _, _,     1,     _, 0) :- !.
	sum_between_triangles(TriangleSR, X, Y, DiffX, DiffY, Sum) :-
		NewDiffX is DiffX - 1,
		NewDiffX > 0,
		NewDiffY is DiffY - 1,
		NewDiffY > 0, !,
		XNew is X + NewDiffX,
		YNew is Y + NewDiffY,
		get_value(TriangleSR, XNew, YNew, Value),
		sum_between_triangles(TriangleSR, X, Y, NewDiffX, NewDiffY, NewSum),
		Sum #= NewSum + Value.
	sum_between_triangles( _, _, _, _, _, _) :- true.

/* END OF CONSTRAINT E */