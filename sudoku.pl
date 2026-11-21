:- use_module(library(clpfd)).
:- use_module(library(http/http_server)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).

% Define routes
:- http_handler(root(.), home, []).
:- http_handler(root(solve), solve_handler, [method(post)]).
:- http_handler(root('style.css'), style_handler, []).
:- http_handler(root('script.js'), script_handler, []).

% Inititalize the http server on port 8080
:- initialization(server(8080), main).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('Sudoku Solver is running at http://localhost:~w/~n', [Port]),
    thread_get_message(_).


home(Request) :-
    http_reply_file('sudoku.html', [], Request).

style_handler(Request) :-
    http_reply_file('style.css', [mime_type(text/css)], Request).

script_handler(Request) :-
    http_reply_file('script.js', [mime_type(text/javascript)], Request).

solve_handler(Request) :-
    catch(
        ( http_read_json_dict(Request, Payload),
          get_dict(grid, Payload, Grid0),
          sudoku_solution(Grid0, Solution)
        ),
        _,
        fail
    ), !,
    reply_json_dict(_{status:success, grid:Solution}).

solve_handler(_Request) :-
    reply_json_dict(_{status:error,
                      message:'Please enter a valid Sudoku with no conflicting clues.'},
                    [status(400)]).

% Convert the submitted 0-filled puzzle into constraints Logic Programming variables,
% then apply the normal Sudoku constraints.
sudoku_solution(Grid, Solution) :-
    valid_grid(Grid),
    maplist(row_with_variables, Grid, Solution),
    append(Solution, Vars),
    Vars ins 1..9,
    maplist(all_distinct, Solution),
    transpose(Solution, Columns),
    maplist(all_distinct, Columns),
    Solution = [R1,R2,R3,R4,R5,R6,R7,R8,R9],
    blocks(R1, R2, R3),
    blocks(R4, R5, R6),
    blocks(R7, R8, R9),
    term_variables(Solution, Variables),
    labeling([], Variables).

valid_grid(Grid) :-
    is_list(Grid),
    length(Grid, 9),
    maplist(valid_row, Grid).

valid_row(Row) :-
    is_list(Row),
    length(Row, 9),
    maplist(valid_cell, Row).

valid_cell(Value) :-
    integer(Value),
    between(0, 9, Value).

row_with_variables([], []).
row_with_variables([0|Rest], [_|Converted]) :-
    row_with_variables(Rest, Converted).
row_with_variables([Value|Rest], [Value|Converted]) :-
    Value in 1..9,
    row_with_variables(Rest, Converted).

blocks([], [], []).
blocks([A,B,C|R1], [D,E,F|R2], [G,H,I|R3]) :-
    all_distinct([A,B,C,D,E,F,G,H,I]),
    blocks(R1, R2, R3).
