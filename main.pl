%room grid
node(1,1). node(1,2). node(1,3). node(1,4).
node(2,1). node(2,2). node(2,3). node(2,4).
node(3,1). node(3,2). node(3,3). node(3,4).
node(4,1). node(4,2). node(4,3). node(4,4).

%objects
object(bed).
object(desc).
object(wardrobe).
object(chair).

%positions 
occupies(bed, 2, 1).
occupies(bed, 2, 2).
occupies(desc, 3, 2).
occupies(wardrobe, 1, 4).
occupies(chair, 3, 3).

%check what object is in the node 
object_at(Row, Col, Object) :-
    occupies(Object, Row, Col).

% Check if a node is part of the grid
is_node(X, Y) :-
    node(X, Y).

%check if node is empty
free(X,Y) :-
  is_node(X,Y),
  \+ occupies(_,X,Y). %\+ negation



%player position 
:- dynamic player_at/2.
player_at(1,1). 

%user interface logic

% Mapping objects to single-letter symbols
symbol_at(X, Y, 'P') :- player_at(X, Y), !.
symbol_at(X, Y, 'B') :- occupies(bed, X, Y), !.
symbol_at(X, Y, 'D') :- occupies(desc, X, Y), !.
symbol_at(X, Y, 'W') :- occupies(wardrobe, X, Y), !.
symbol_at(X, Y, 'C') :- occupies(chair, X, Y), !.
symbol_at(X, Y, '.') :- is_node(X, Y).

print_row(Row) :-
    print_row(Row, 1, 4), nl.

print_row(_, Col, MaxCol) :- Col > MaxCol, !.
print_row(Row, Col, MaxCol) :-
    symbol_at(Row, Col, Sym),
    write(Sym), write(' '),
    NextCol is Col + 1,
    print_row(Row, NextCol, MaxCol).

print_grid :-
    print_grid(1, 4).

print_grid(Row, MaxRow) :-
    Row > MaxRow, !.
print_grid(Row, MaxRow) :-
    print_row(Row),
    NextRow is Row + 1,
    print_grid(NextRow, MaxRow).

%movement logic
delta(up, -1, 0).
delta(down, 1, 0).
delta(left, 0, -1).
delta(right, 0, 1).


move_to(X,Y) :-
  free(X,Y),
  retract(player_at(_,_)), %remove fact
  assertz(player_at(X,Y)). %adds fact at the end of the db


move(Direction) :-
    player_at(X, Y),
    delta(Direction, DX, DY),
    NX is X + DX,
    NY is Y + DY,
    (   move_to(NX, NY)
    ->  format('Moved ~w to (~w, ~w).~n', [Direction, NX, NY])
    ;   writeln('Cannot move there.')
    ).

  
game_loop :-
    print_grid,
    write('Enter command (up, down, left, right, exit): '),
    read(Command),
    handle_command(Command).

handle_command(exit) :-
    writeln('Leaving the game!'), !.

handle_command(Direction) :-
    move(Direction),
    nl,
    game_loop.

handle_command(_) :-
    writeln('Invalid command.'), nl,
    game_loop.








