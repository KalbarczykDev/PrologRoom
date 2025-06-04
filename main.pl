% Game Config
grid_size(10,10).

%Dynamic State
:- dynamic has_key/0. %elementy dymaniczne
:- dynamic player_at/2.
player_at(2,2).

%Grid Definition
is_node(X, Y) :-
    grid_size(MaxRow, MaxCol),
    between(1, MaxRow, X),
    between(1, MaxCol, Y).

% chests      
occupies(chest, 9, 9).      
occupies(chest, 4, 8).     
occupies(chest, 4, 2).         
occupies(chest, 9, 9).% final chest



%exit door 
occupies(door, 5, 10).


% Top and bottom borders (horizontal walls)
occupies(h_wall, 1, 1). occupies(h_wall, 1, 2). occupies(h_wall, 1, 3). occupies(h_wall, 1, 4). occupies(h_wall, 1, 5). % 7a Termy/termy złożone 
occupies(h_wall, 1, 6). occupies(h_wall, 1, 7). occupies(h_wall, 1, 8). occupies(h_wall, 1, 9). occupies(h_wall, 1, 10).

occupies(h_wall, 10, 1). occupies(h_wall, 10, 2). occupies(h_wall, 10, 3). occupies(h_wall, 10, 4). occupies(h_wall, 10, 5).
occupies(h_wall, 10, 6). occupies(h_wall, 10, 7). occupies(h_wall, 10, 8). occupies(h_wall, 10, 9). occupies(h_wall, 10, 10).

% Left and right borders (vertical walls)
occupies(v_wall, 2, 1). occupies(v_wall, 3, 1). occupies(v_wall, 4, 1). occupies(v_wall, 5, 1). occupies(v_wall, 6, 1).
occupies(v_wall, 7, 1). occupies(v_wall, 8, 1). occupies(v_wall, 9, 1). occupies(h_wall, 10, 1).

occupies(v_wall, 2, 10). occupies(v_wall, 3, 10). occupies(v_wall, 4, 10). occupies(v_wall, 6, 10).
occupies(v_wall, 7, 10). occupies(v_wall, 8, 10). occupies(v_wall, 9, 10).

% Inner vertical walls
occupies(v_wall, 3, 3). occupies(v_wall, 4, 3). occupies(v_wall, 5, 3).
occupies(v_wall, 8, 3). occupies(v_wall, 9, 3).

occupies(v_wall, 2, 6). 
occupies(v_wall, 6, 6). occupies(v_wall, 7, 6). occupies(v_wall, 8, 6).

occupies(v_wall, 5, 8). occupies(v_wall, 6, 8). occupies(v_wall, 7, 8).

% Inner horizontal walls
occupies(h_wall, 3, 2). occupies(h_wall, 3, 3). occupies(h_wall, 3, 4).
occupies(h_wall, 6, 3). occupies(h_wall, 6, 4).
occupies(h_wall, 8, 5). occupies(h_wall, 8, 6). occupies(h_wall, 8, 7).



free(X, Y) :- %klauzule
    is_node(X, Y),
     (
        \+ occupies(_, X, Y)      
    ;
        occupies(chest, X, Y)             
    ;
        occupies(door, X, Y)             
     ),
    \+ occupies(v_wall, X, Y),
    \+ occupies(h_wall, X, Y).

%symbol mapping 
symbol_at(X, Y, '@') :- player_at(X, Y), !. %cięcie 
symbol_at(X, Y, 'T') :- occupies(chest, X, Y), !.
symbol_at(X, Y, 'D') :- occupies(door, X, Y), !.
symbol_at(X, Y, '|') :- occupies(v_wall, X, Y), !.
symbol_at(X, Y, '=') :- occupies(h_wall, X, Y), !.
symbol_at(X, Y, '.')  :- is_node(X, Y).

%printing
print_row(Row) :-
    grid_size(_, MaxCol),
    print_row(Row, 1, MaxCol), nl.

print_row(_, Col, MaxCol) :- Col > MaxCol, !.
print_row(Row, Col, MaxCol) :-
    symbol_at(Row, Col, Sym),
    write(Sym), write(' '),
    NextCol is Col + 1,
    print_row(Row, NextCol, MaxCol).

print_grid :-
    grid_size(MaxRow, _),
    print_grid(1, MaxRow).

%rekurencja 

print_grid(Row, MaxRow) :-
    Row > MaxRow, !.
print_grid(Row, MaxRow) :-
    print_row(Row),
    NextRow is Row + 1,
    print_grid(NextRow, MaxRow).

%unifikacja
%movement
delta(u, -1, 0). %up
delta(d, 1, 0). %down 
delta(l, 0, -1). %left
delta(r, 0, 1). %right


move(Direction) :-
    player_at(X, Y),
    delta(Direction, DX, DY),
    NX is X + DX,
    NY is Y + DY,
    (   move_to(NX, NY)
    ->  format('New position (~w, ~w).~n', [NX, NY]),
        post_move_action(NX, NY)
    ;   writeln('Cannot move there.')
    ).

move_to(X, Y) :-
    free(X, Y),
    retract(player_at(_, _)),
    assertz(player_at(X, Y)).

%ambient messages
ambient_message("Winds howling...").
ambient_message("You hear distant footsteps...").
ambient_message("A cold breeze passes by.").
ambient_message("You step on something... but it's just a stone.").
ambient_message("Your footsteps echo through the maze.").
ambient_message("Places like this... always hide something.").
ambient_message("Not a soul in sight. That’s never a good sign.").
random_ambient_message :-
    findall(Msg, ambient_message(Msg), Messages), %list/operacje na listach 
    random_member(Msg, Messages),
    writeln(Msg).


%interactions
post_move_action(X, Y) :-
    (   occupies(chest, X, Y)
    ->  open_chest(X, Y)
    ;   occupies(door, X, Y)
    ->  (   has_key ->
            writeln('You used the key and opened the door. You win!'), halt
        ;   writeln('The door is locked. Maybe there\'s a key somewhere?')
        )
    ;   random_ambient_message
    ).

open_chest(X, Y) :-
    (   X = 9, Y = 9 ->
        (   has_key -> writeln('You already have the key.')
        ;   assertz(has_key),
            writeln('You opened the final chest... You found the KEY!')
        )
    ;   writeln('You opened the chest. It\'s empty.')
    ).

%game loop
game_loop :-    
    print_grid,
write('Enter command (u-up, d-down, l-left, r-right, exit): '),
    read(Command),
    handle_command(Command).

handle_command(exit) :-
    writeln('Leaving the game!'), !,
    halt.

handle_command(Direction) :-
    move(Direction), nl,
    game_loop.

handle_command(_) :-
    writeln('Invalid command.'), nl,
    game_loop.

start :-
    nl,
    writeln("██████████████████████████████████████████████"),
    writeln("█                                            █"),
    writeln("█        WELCOME TO THE PROLOG ROOM          █"),
    writeln("█                                            █"),
    writeln("██████████████████████████████████████████████"),
    writeln("You wake up in a dark, silent labyrinth..."),
    writeln("Somewhere in the maze lies a hidden key."),
    writeln("Find it and escape through the locked door."),
    writeln("Use 'u', 'd', 'l', 'r' to move. Type 'exit' to quit."),
    writeln("Good luck, wanderer."),
    nl,
    game_loop.
