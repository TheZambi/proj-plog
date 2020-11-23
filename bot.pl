value(GameState, Player, Value):-
    [Board, ColorsWon | _] = GameState,
    captured_color_value(Player, ColorsWon, ColorValue),
    getPathValue(Player,ColorsWon,Board,PathValue),
    NewP is mod(Player+1,2),
    Value is 0.
    % getPathValue(NewP,ColorsWon,Board,Player2PathValue),
    % Value is ColorValue + PathValue - Player2PathValue.

captured_color_value(Player, ColorsWon,ColorValue):-
    count_occurrences(ColorsWon,Player,CountOfPlayer),
    NewP is mod(Player+1,2),
    count_occurrences(ColorsWon,NewP,CountOfOpponent),
    AuxValue is 0 + CountOfPlayer * 50,
    ColorValue is AuxValue - (CountOfOpponent * 50).

iterateRow([],_,_,_,NewListOfMoves,NewListOfMoves).
iterateRow(Row,CurrentRow,CurrentDiagonal,NPieces,ListOfMoves,FinalListOfMoves):-
    [Value | T ] = Row,
    [Orange, Purple, Green] = NPieces,
    (
        (
            Value \== empty,
            AuxOrange = [],
            AuxPurple = [],
            AuxGreen = []
        );
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

valid_moves(GameState, _Player ,FinalListOfMoves):-
    [Board, _ , NPieces] = GameState,
    iterateBoard(Board,NPieces,0,_ , AuxFinalListOfMoves),
    remove_dups(AuxFinalListOfMoves, NoDuplicateListOfMoves),
    delete(NoDuplicateListOfMoves,[], FinalListOfMoves).

getPathValue(Player,ColorsWon,Board,PathValue):-
    [Orange,Purple,Green] = ColorsWon,
    (
        (Orange \== -1, Length is 2) ; 
        getOrangePathLength(Player,Board,Length)
    ),
    (
        (Purple \==  -1, Length1 is 2);
        getPurplePathLength(Player,Board,Length1)
    ),
    (
        (Green \==  -1, Length2 is 2); 
        getGreenPathLength(Player,Board,Length2)
    ),
    AuxValue is (2-Length)*4,
    AuxValue1 is (2-Length1)*4,
    AuxValue2 is (2-Length2)*4,
    PathValue is AuxValue + AuxValue1 + AuxValue2.
 
getOrangePathLength(Player,Board,Length):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]],
    allied(Player,orange,Allied),
    buildLevel(Board,[],ReturnLevel,ToVisit,[],Allied,orange),
    write(ReturnLevel),
    getPathLength(Board,Level1,Allied,orange,Length).


getPurplePathLength(Player,Board,Length):-
    ToVisit = [[18,7],[19,8],[20,9],[21,10],[22,11]],
    allied(Player,purple,Allied),
    buildLevel(Board,[],ReturnLevel,ToVisit,[],Allied,purple),
    getPathLength(Board,Level1,Allied,purple,Length).

getGreenPathLength(Player,Board,Length):-
    ToVisit = [[7,1],[9,2],[11,3],[13,4],[15,5]],
    allied(Player,green,Allied),
    buildLevel(Board,[],ReturnLevel,ToVisit,[],Allied,green),
    getPathLength(Board,Level1,Allied,green,Length).
    

buildLevel(_,Level1,Level1,[],_,_,_).
buildLevel(Board,Level1,ReturnLevel,ToVisit,Visited,Allied,CheckingColor):-
    % trace,
    % write(ToVisit),nl,
    [H|T] = ToVisit,
    % write(ToVisit),nl,
    % write(Visited), nl, 
    [Row,Diagonal | _] = H,
    (
        (
            \+member(H,Visited),
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Row,Color),
            (
                (
                    (Color == Allied; Color == CheckingColor),
                    getNeighbours(Row,Diagonal,Neighbours),
                    append(Neighbours,T,Aux),
                    append([H],Visited,Aux2),
                    remove_dups(Aux,NoDupes),
                    %write('Allied or Color, adding neighbours : '),write(Row),write('  '),write(Diagonal),nl,
                    buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,Allied,CheckingColor)
                );
                (
                    (Color == empty),
                    %getNeighbours(Row,Diagonal,Neighbours),
                    %append(Neighbours,T,Aux),
                    append([H],Visited,Aux2),
                    remove_dups(T,NoDupes),
                    buildLevel(Board,[H|Level1],ReturnLevel,NoDupes,Aux2,Allied,CheckingColor)
                );
                (
                    getNeighbours(Row,Diagonal,Neighbours),
                    append(Neighbours,T,Aux),
                    append([H],Visited,Aux2),
                    remove_dups(Aux,NoDupes),
                    buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,Allied,CheckingColor)
                )
            )
        ); 
        (
            append([H],Visited,Aux2),
            remove_dups(T,NoDupes),
            buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,Allied,CheckingColor)
        )
    ).



getPathLength(Board,Level,Allied,CheckingColor,Depth):-
    



get_random_move([Move|_],0,Move).
get_random_move(ListOfMoves,RandomMove,Move):-
    NewRandomMove is RandomMove-1,
    [_ | T] = ListOfMoves,
    get_random_move(T, NewRandomMove, Move).

choose_move(GameState,Player,1,Move):- 
    valid_moves(GameState,Player, ListOfMoves),
    length(ListOfMoves,Length),
    random(0,Length,RandomMove),
    get_random_move(ListOfMoves,RandomMove,Move), sleep(1).

choose_move(GameState,Player,2,Move):- 
    valid_moves(GameState,Player, ListOfMoves),
    simMoves(GameState,ListOfMoves,Player,_BestMove,-10000, Move),
    [Row,Diagonal,Color] = Move, nl,
    write('Putting piece of color '), write(Color), write(' at row '), write(Row), write(' and diagonal '), write(Diagonal).

simMoves(_,[],_, BestMove,_, BestMove).
simMoves(GameState,ListOfMoves,Player, BestMove,BestMoveValue, FinalBestMove):-
    [_, ColorsWon, NPieces] = GameState,
    [Move | T] = ListOfMoves,
    updateNPieces(Move,NPieces,_),
    move(GameState, Move, NewGameState),    
    [NewBoard | _] = NewGameState,
    updateColorsWon([NewBoard, ColorsWon], NewColorsWon, Player),
    value([NewBoard,NewColorsWon], Player, Value),
    (
        (
        Value > BestMoveValue,
        simMoves(GameState,T,Player,Move,Value,FinalBestMove)
        ); simMoves(GameState,T,Player,BestMove,BestMoveValue,FinalBestMove)
    ).
    