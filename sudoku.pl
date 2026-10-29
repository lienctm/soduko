/*********************************************************
 Project: Sudoku solver using Prolog
 Student: Lien Cao, Yamaguchi Mari
 Class: CS152 Fall 26, SJSU
**********************************************************/

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
    all_distinct([E1, E2, E3,
                  E4, E5, E6,
                  E7, E8, E9]),

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


% Example Sudoku puzzle.
% Use 0 for empty cells.
example([
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 0, 0, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9]
]).


% Solve the example puzzle and print the answer.
solve_example :-
    example(Rows),
    solve(Rows),
    print_sudoku(Rows).
