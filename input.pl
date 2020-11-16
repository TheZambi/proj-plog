:- use_module(library(lists)).

diagonal_index(0,0).
diagonal_index(1,0).
diagonal_index(2,0).
diagonal_index(3,0).
diagonal_index(4,0).
diagonal_index(5,1).
diagonal_index(6,1).
diagonal_index(7,1).
diagonal_index(8,2).
diagonal_index(9,2).
diagonal_index(10,3).
diagonal_index(11,3).
diagonal_index(12,4).
diagonal_index(13,4).
diagonal_index(14,5).
diagonal_index(15,5).
diagonal_index(16,6).
diagonal_index(17,7).
diagonal_index(18,7).
diagonal_index(19,8).
diagonal_index(20,9).
diagonal_index(21,10).
diagonal_index(22,11).

diagonal_index_end(0,1).
diagonal_index_end(1,2).
diagonal_index_end(2,3).
diagonal_index_end(3,4).
diagonal_index_end(4,5).
diagonal_index_end(5,5).
diagonal_index_end(6,6).
diagonal_index_end(7,7).
diagonal_index_end(8,7).
diagonal_index_end(9,8).
diagonal_index_end(10,8).
diagonal_index_end(11,9).
diagonal_index_end(12,9).
diagonal_index_end(13,10).
diagonal_index_end(14,10).
diagonal_index_end(15,11).
diagonal_index_end(16,11).
diagonal_index_end(17,11).
diagonal_index_end(18,12).
diagonal_index_end(19,12).
diagonal_index_end(20,12).
diagonal_index_end(21,12).
diagonal_index_end(22,12).


valid_color(Color,NPieces):-
    [Orange, Purple, Green | _ ] = NPieces,
    atom(Color),
    (
      (Color == 'O', (Orange > 0; (write('No Orange Pieces Left.'), nl,fail) ));
      (Color == 'G', (Green > 0; (write('No Green Pieces Left.'), nl,fail) ));
      (Color == 'P', (Purple > 0; (write('No Purple Pieces Left.'), nl,fail) ))
    ).

get_line(Line):-
    repeat,
        write('Insert move line (0-22): '),
        read(Line),
        valid_line(Line),!.

get_diagonal(Diagonal, Line):-
    diagonal_index(Line, D1),
    diagonal_index_end(Line, D2),
    repeat,
        write('Insert move diagonal ('), write(D1), write('-'), write(D2), write(') :'),
        read(Diagonal),
        valid_diagonal(Diagonal,D1,D2),!.
  
get_color(Color,NPieces):-
    repeat,
        write('Insert move color (\'O\',\'P\',\'G\'): '),
        read(Aux),
        valid_color(Aux,NPieces),
        (
          (
            Aux == 'O',
            Color = orange
          );
          (
            Aux == 'P',
            Color = purple
          );
          (
            Aux == 'G',
            Color = green
          )
        ),!.

is_empty(Line,Diagonal,Board):-
    nth0(Line,Board,Row),
    diagonal_index(Line,X),
    Diagonal_index_in_row is Diagonal - X,
    nth0(Diagonal_index_in_row,Row,Elem),
    (
      (
        Elem == empty
      );
      (
        write('Invalid move, tile is not empty.'), nl,
        fail
      )
    ).

get_move([Line,Diagonal,Color],Board, NPieces):-
    repeat,
        get_line(Line), 
        get_diagonal(Diagonal, Line),
        is_empty(Line,Diagonal,Board),!, 
    get_color(Color,NPieces).