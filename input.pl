:- use_module(library(lists)).

% Used to turn the input char into a color.
parse_color('O',orange).  
parse_color('P',purple).  
parse_color('G',green).

% Facts with the first diagonal index of each row.
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

% Facts with the last diagonal index of a row.
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

writePiecesLeft('O',NPieces):-
  NPieces =< 0, 
  write('No Orange Pieces Left.'), nl, fail.
writePiecesLeft('O', NPieces):-
  NPieces>0.

writePiecesLeft('P',NPieces):-
  NPieces =< 0, 
  write('No Purple Pieces Left.'), nl, fail.
writePiecesLeft('P', NPieces):-
  NPieces>0.

writePiecesLeft('G',NPieces):-
  NPieces =< 0, 
  write('No Green Pieces Left.'), nl, fail.
writePiecesLeft('G', NPieces):-
  NPieces>0.

getColor(Orange,_,_,'O',Orange).
getColor(_,Purple,_,'P',Purple).
getColor(_,_,Green,'G',Green).

% Used to validate the input color.
valid_color(Color,[Orange, Purple, Green | _ ]):-
    atom(Color),
    getColor(Orange,Purple,Green,Color,FinalColor),
    writePiecesLeft(Color,FinalColor).

% Used to read a line.
get_line(Line):-
    repeat,
        write('Insert move line (0-22): '),
        catch(read(Line),_,true),
        valid_line(Line),!.

% Used to read a diagonal.
get_diagonal(Diagonal, Line):-
    diagonal_index(Line, D1),
    diagonal_index_end(Line, D2),
    repeat,
        write('Insert move diagonal ('), write(D1), write('-'), write(D2), write(') :'),
        catch(read(Diagonal),_,true),
        valid_diagonal(Diagonal,D1,D2),!.

% Used to read a color.
get_color(Color,NPieces):-
    skip_line,
    repeat,
        write('Insert move color (O, P, G): '),
        catch(get_char(Aux),_,true),
        skip_line,
        valid_color(Aux,NPieces),
        parse_color(Aux,Color),
        !.

errorMessage(empty).
errorMessage(_):-
  write('Invalid move, tile is not empty.'), nl,
  fail.

% Used to check if a tile is empty
is_empty(Line,Diagonal,Board):-
    nth0(Line,Board,Row),
    diagonal_index(Line,X),
    Diagonal_index_in_row is Diagonal - X,
    nth0(Diagonal_index_in_row,Row,Elem),
    errorMessage(Elem).

% Function used to get a move by calling the functions to get the line, diagonal and color. After that checks if the color is empty.
get_move([Line,Diagonal,Color],Board, NPieces):-
    repeat,
        get_line(Line), 
        get_diagonal(Diagonal, Line),
        is_empty(Line,Diagonal,Board),!, 
    get_color(Color,NPieces).