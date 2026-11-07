:- use_module(library(clpfd)).

sudoku(Rows, Cols) :-
    % Every row contains numbers from 1 to 9 without repetition.
    length(Rows, 9),
    maplist(same_length(Rows), Rows),
    append(Rows, Vars),
    Vars ins 1..9,
    maplist(all_distinct, Rows),

    % Every column contains numbers from 1 to 9 without repetition.
    transpose(Rows, Cols),
    maplist(all_distinct, Cols),

    % Every 3 x 3 subgrid contains numbers from 1 to 9 without repetition.
    Rows = [R1, R2, R3, R4, R5, R6, R7, R8, R9],

    subRows(R1, R2, R3),
    subRows(R4, R5, R6),
    subRows(R7, R8, R9).


% Check each 3 x 3 subgrid.
subRows([], [], []).

subRows(
    [E1, E2, E3 | Remain1],
    [E4, E5, E6 | Remain2],
    [E7, E8, E9 | Remain3]
) :-
    all_distinct([E1, E2, E3, E4, E5, E6, E7, E8, E9]),
    subRows(Remain1, Remain2, Remain3).


% Solve the Sudoku puzzle.
solve(Rows) :-
    sudoku(Rows, _Cols),
    append(Rows, Vars),
    labeling([], Vars).


% Display the solved Sudoku.
print_sudoku([]).

print_sudoku([Row | Rest]) :-
    writeln(Row),
    print_sudoku(Rest).


% Examples Sudoku puzzle.
% Use 0 for empty cells.
example_easy([
    [7, 4, 1, 8, 2, 5, 0, 9, 0],
    [0, 0, 5, 0, 3, 9, 0, 0, 7],
    [2, 0, 9, 6, 7, 0, 8, 0, 1],
    [0, 1, 2, 9, 0, 0, 6, 8, 0],
    [3, 6, 8, 4, 1, 0, 0, 0, 0],
    [0, 0, 7, 3, 0, 8, 1, 0, 6],
    [5, 2, 3, 7, 9, 6, 4, 0, 0],
    [0, 7, 6, 2, 4, 1, 9, 3, 5],
    [1, 9, 0, 5, 8, 3, 0, 6, 0]
]).

example_medium([
    [0, 9, 0, 1, 3, 2, 7, 6, 5],
    [7, 1, 5, 0, 4, 6, 0, 3, 2],
    [0, 2, 3, 5, 0, 0, 4, 1, 0],
    [0, 0, 0, 0, 9, 3, 0, 4, 0],
    [0, 7, 9, 0, 0, 0, 0, 0, 6],
    [4, 6, 1, 0, 8, 5, 0, 9, 3],
    [0, 5, 0, 0, 0, 0, 0, 2, 9],
    [2, 0, 0, 0, 5, 0, 0, 7, 1],
    [0, 0, 0, 0, 1, 0, 0, 0, 4]
]).


example_hard([
    [0, 0, 0, 1, 3, 0, 7, 0, 0],
    [0, 1, 5, 0, 4, 0, 0, 0, 2],
    [0, 2, 0, 5, 7, 0, 0, 0, 8],
    [0, 8, 2, 6, 0, 0, 1, 0, 0],
    [0, 0, 9, 0, 0, 0, 0, 0, 6],
    [4, 6, 1, 0, 8, 0, 0, 0, 3],
    [0, 0, 7, 0, 0, 0, 0, 0, 9],
    [0, 0, 6, 9, 0, 0, 3, 7, 1],
    [0, 3, 0, 0, 0, 7, 0, 0, 0]
]).


% Solve the example puzzle and print the answer.
solve_example :-
    example_easy(Rows),
    example_medium(Rows),
    example_hard(Rows),
    solve(Rows),
    print_sudoku(Rows).
