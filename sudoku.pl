/*********************************************************
 Project: Sudoku solver using Prolog
 Student: Lien Cao, Yamaguchi Mari
 Class: CS152 Fall 26, SJSU
**********************************************************/

:- use_module(library(clpfd)).

sudoku(Rows, Cols) :-
    % Every row contains the number from 1 to 9 without repetition.
    length(Rows, 9),
    maplist(same_length(Rows), Rows),
    append(Rows, Vars),
    Vars ins 1..9,
    maplist(all_distinct, Rows),
   
    % Every colum contains the number form 1 to 9 without repetition.
    transpose(Rows, Cols),
    maplist(all_distinct, Cols),
    
    % Every 3 x 3 subgrid contains the numbers from 1 to 9 without repetition.
    Rows = [R1, R2, R3, R4, R5, R6, R7, R8, R9],
    subRows(R1, R2, R3),
    subRows(R4, R5, R6),
    subRows(R7, R8, R9).

subRows([], [], []).  % base case
subRows([e1, e2, e3 | remain1],
        [e4, e5, e6 | remain2],
        [e7, e8, e9 | remain3]) :-
            all_distinct([e1, e2, e3, e4, e5, e6, e7, e8, e9]),
            subRows(remain1, remain2, remain3).

