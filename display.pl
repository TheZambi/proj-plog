
initial([
              [empty,empty],                           %even
            [empty,empty,empty],                       %odd
          [empty,empty,empty,empty],                   %even
        [empty,empty,empty,empty,empty],               %odd
      [empty,empty,empty,empty,empty,empty],           %even
        [empty,empty,empty,empty,empty],               %odd
      [empty,empty,empty,orange,empty,empty],           %even
    [empty,empty,empty,empty,empty,empty,empty],       %odd
      [empty,empty,empty,empty,empty,empty],           %even
    [empty,empty,empty,empty,empty,empty,empty],       %odd
      [empty,empty,empty,empty,empty,empty],           %even
    [empty,empty,empty,empty,empty,empty,empty],
      [empty,green,empty,empty,empty,empty],
    [empty,empty,empty,empty,empty,empty,empty],
      [empty,empty,empty,empty,empty,empty],
    [empty,empty,purple,empty,empty,empty,empty],
      [empty,empty,empty,empty,empty,empty],
        [empty,empty,empty,empty,empty],
      [empty,empty,empty,empty,empty,empty],
        [empty,empty,empty,empty,empty],
          [empty,empty,empty,empty],
            [empty,empty,empty],
              [orange,orange]
]).

cell_val(orange, 'O').
cell_val(green, 'G').
cell_val(purple, 'P').
cell_val(empty, ' ').

even_row(0).
even_row(2).
even_row(4).
even_row(6).
even_row(8).
even_row(10).
even_row(2).
even_row(14).
even_row(16).
even_row(18).
even_row(20).
even_row(22).

start_value(0,'    ___/ ').
start_value(1,'org ___/ ').
start_value(2,'    ___/ ').
start_value(3,'    ___/ ').
start_value(4,'       / ').
start_value(5,'   \\___/ ').
start_value(6,'    ___/ ').
start_value(7,'       / ').
start_value(8,'   \\___/ ').
start_value(9,'       / ').
start_value(10,'   \\___/ ').
start_value(11,'   grn / ').
start_value(12,'   \\___/ ').
start_value(13,'       / ').
start_value(14,'   \\___/ ').
start_value(15,'       / ').
start_value(16,'   \\___/ ').
start_value(17,'   \\___/ ').
start_value(18,'       / ').
start_value(19,'   \\___/ ').
start_value(20,'   \\___/ ').
start_value(21,'prp\\___/ ').
start_value(22,'   \\___/ ').

end_value(0,'___2                     ').
end_value(1,'___3   prp           ').
end_value(2,'___4             ').
end_value(3,'___5         ').
end_value(4,'         ').
end_value(5,'___/6        ').
end_value(6,'___      ').
end_value(7,'7    ').
end_value(8,'___/     ').
end_value(9,'8    ').
end_value(10,'___/     ').
end_value(11,'9 grn').
end_value(12,'___/     ').
end_value(13,'10   ').
end_value(14,'___/     ').
end_value(15,'11   ').
end_value(16,'___/     ').
end_value(17,'___/         ').
end_value(18,'12       ').
end_value(19,'___/         ').
end_value(20,'___/             ').
end_value(21,'___/ org             ').
end_value(22,'___/                     ').

max_length_odd(7).    
max_length_even(6).

writeNspaces(0).
writeNspaces(X):-
    write(' '),
    NX is X-1,
    (
      (
        NX<0,
        writeNspaces(0)
      );
      (
        writeNspaces(NX)
      )
    ).

display_piece([],_,_).
display_piece(H,Nrow,NPiece) :-
    [V | T] = H,
    (
      (
        (NPiece == 0),
        start_value(Nrow,X),
        write(X)
      );
      write('___/ ')
    ),
    cell_val(V,Piece),
    write(Piece),
    write(' \\'),
    display_piece(T,Nrow,1).


close_hex_top:-
    writeNspaces(31), write('Column'),writeNspaces(31),write('Line'),nl,
    writeNspaces(28),
    write('___0'),
    writeNspaces(4),
    write('___1'), nl.

close_hex_bot:-
    writeNspaces(27),
    write('\\___/'),
    writeNspaces(3),
    write('\\___/'), nl.


display_line(H,NRow) :-

    length(H,L),
    (
      (
        even_row(NRow),
        max_length_even(X),
        N is (X - L) * 4,
        writeNspaces(4+N)
      );
      (
        max_length_odd(X),
        N is (X - L) * 4,
        writeNspaces(N)
      )
    ),
    display_piece(H,NRow,0), 
    end_value(NRow,Line),
    write(Line),
    write('   '), write(NRow), nl.
    

display_board([],_,_).
display_board(GameState,Player,NRow) :-
    [H | T] = GameState,
    display_line(H,NRow),
    NewRow is NRow+1,
    display_board(T,Player,NewRow).

display_player(Player):-
    P is Player+1,
    write('Current Player: ') , write(P), nl.

display_remaining_pieces :-
    write('Current Orange Pieces Left: 42'), nl,
    write('Current Purple Pieces Left: 42'), nl,
    write('Current Green Pieces Left: 42'), nl.

display_alliances:-
    write('Player 1 alliances: To connect Orange: Orange-Green, to connect Green: Green-Purple, to connect Purple: Purple-Orange'), nl,
    write('Player 2 alliances: To connect Orange: Orange-Purple, to connect Green: Green-Orange, to connect Purple: Purple-Green'), nl.

display_game(GameState,Player):-
    close_hex_top,
    display_board(GameState,Player,0),
    close_hex_bot,
    display_player(Player),
    display_remaining_pieces,
    display_alliances.

