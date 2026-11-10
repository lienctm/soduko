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


% Easy Sudoku puzzle.
% "_" represents an empty cell.
example(easy, [
    [7, 4, 1, 8, 2, 5, _, 9, _],
    [_, _, 5, _, 3, 9, _, _, 7],
    [2, _, 9, 6, 7, _, 8, _, 1],
    [_, 1, 2, 9, _, _, 6, 8, _],
    [3, 6, 8, 4, 1, _, _, _, _],
    [_, _, 7, 3, _, 8, 1, _, _],
    [5, 2, 3, 7, 9, 6, 4, _, _],
    [_, 7, 6, 2, 4, 1, 9, 3, 5],
    [1, 9, _, 5, 8, 3, _, 6, _]
]).

example(medium, [
    [_, 9, _, 1, 3, 2, 7, 6, 5],
    [7, 1, 5, _, 4, 6, _, 3, 2],
    [_, 2, 3, 5, _, _, 4, 1, _],
    [_, _, _, _, 9, 3, _, 4, _],
    [_, 7, 9, _, _, _, _, _, 6],
    [4, 6, 1, _, 8, 5, _, 9, 3],
    [_, 5, _, _, _, _, _, 2, 9],
    [2, _, _, _, 5, _, _, 7, 1],
    [_, _, _, _, 1, _, _, _, 4]
]).


example(hard, [
    [2, 1, _, _, 8, _, _, 4, _],
    [5, 4, _, _, 9, _, _, _, 8],
    [7, 6, 8, _, _, 5, _, 2, _],
    [_, 7, _, _, 5, _, _, _, 1],
    [8, 3, _, _, _, _, _, _, 7],
    [_, 9, 5, _, 4, 7, 2, 3, _],
    [_, _, _, 5, _, _, _, 6, 2],
    [_, 5, 7, _, 6, 3, _, 1, 4],
    [_, _, 6, _, _, _, _, _, _]
]).


% Solve the example puzzle and print the answer.
solve_example(Level) :-
    example(Level, Rows),
    solve(Rows),
    print_sudoku(Rows).
