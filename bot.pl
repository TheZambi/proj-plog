value(GameState, Player, Value):-
    [Board, ColorsWon | _] = GameState,
    captured_color_value(ColorsWon, ColorValue),
    Value is ColorValue.

captured_color_value(ColorsWon,ColorValue):-
    count_occurrences(ColorsWon,0,CountOfZero),
    count_occurrences(ColorsWon,1,CountOfOne),
    AuxValue is 0 + CountOfZero * 50,
    ColorValue is AuxValue - (CountOfOne * 50).

iterateRow([],_,_,_,NewListOfMoves,NewListOfMoves).
iterateRow(Row,CurrentRow,CurrentDiagonal,NPieces,ListOfMoves,FinalListOfMoves):-
    [Value | T ] = Row,
    [Orange, Purple, Green] = NPieces,
    (
        Value \== empty; 
        (
            addOrangeMove(CurrentRow,CurrentDiagonal,Orange,AuxOrange),
            addPurpleMove(CurrentRow,CurrentDiagonal,Purple,AuxPurple),
            addGreenMove(CurrentRow,CurrentDiagonal,Green,AuxGreen)
        )
    ),
    append([AuxPurple],[AuxOrange],AuxList),
    append(AuxList,[AuxGreen],NewAuxList),
    append(ListOfMoves,NewAuxList,NewListOfMoves),
    NewDiagonal is CurrentDiagonal +1,
    iterateRow(T,CurrentRow,NewDiagonal,NPieces,NewListOfMoves,FinalListOfMoves).
    
addOrangeMove(CurrentRow,CurrentDiagonal,Orange,AuxOrange):-
    (
        Orange > 0,
        AuxOrange = [CurrentRow,CurrentDiagonal,orange]
    );
    (
    AuxOrange = []
    ).

addGreenMove(CurrentRow,CurrentDiagonal,Green,AuxGreen):-
    (
        Green > 0,
        AuxGreen = [CurrentRow,CurrentDiagonal,green]
    );
    (
    AuxGreen = []
    ). 

addPurpleMove(CurrentRow,CurrentDiagonal,Purple,AuxPurple):-
    (
        Purple > 0,
        AuxPurple = [CurrentRow,CurrentDiagonal,purple]
    );
    (
    AuxPurple = []
    ). 



iterateBoard([],_,_,FinalListOfMoves,FinalListOfMoves).
iterateBoard(Board,NPieces,CurrentRow,ListOfMoves,FinalListOfMoves):-    
    [Row | T ] = Board,
    diagonal_index(CurrentRow,Diagonal),
    iterateRow(Row,CurrentRow,Diagonal,NPieces,ListOfMoves,RowListOfMoves),
    NewRow is CurrentRow+1,
    iterateBoard(T,NPieces,NewRow,RowListOfMoves,FinalListOfMoves).

valid_moves(GameState, Player,FinalListOfMoves):-
    [Board, _ , NPieces] = GameState,
    iterateBoard(Board,NPieces,0,AuxListOfMoves, FinalListOfMoves).
    