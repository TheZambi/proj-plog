value(GameState, Player, Value):-
    [Board, ColorsWon | _] = GameState,
    captured_color_value(Player, ColorsWon, ColorValue),
    getPathValue(Player,ColorsWon,Board,PathValue),
    NewP is mod(Player+1,2),
    getPathValue(NewP,ColorsWon,Board,Player2PathValue),
    Value is ColorValue + PathValue - Player2PathValue.

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
        (Orange \== -1, Length is 5) ; 
        getOrangePathLength(Player,Board,Length)
    ),
    (
        (Purple \==  -1, Length1 is 5);
        getPurplePathLength(Player,Board,Length1)
    ),
    (
        (Green \==  -1, Length2 is 5); 
        getGreenPathLength(Player,Board,Length2)
    ),
    AuxValue is (5-Length)*4,
    AuxValue1 is (5-Length1)*4,
    AuxValue2 is (5-Length2)*4,
    PathValue is AuxValue + AuxValue1 + AuxValue2.
    %write(PathValue).
 
getOrangePathLength(Player,Board,Length):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]],
    allied(Player,orange,Allied),
    getPathLengthWrapper(Board,ToVisit,[],Allied,orange,1,Length).


getPurplePathLength(Player,Board,Length):-
    ToVisit = [[18,7],[19,8],[20,9],[21,10],[22,11]],
    allied(Player,purple,Allied),
    getPathLengthWrapper(Board,ToVisit,[],Allied,purple,1,Length).

getGreenPathLength(Player,Board,Length):-
    ToVisit = [[7,1],[9,2],[11,3],[13,4],[15,5]] ,
    allied(Player,green,Allied),
    getPathLengthWrapper(Board,ToVisit,[],Allied,green,1,Length).
    
getPathLengthWrapper(Board,ToVisit,[],Allied,Color,Depth,Length):-
    (
        Depth =:= 5,
        Length is Depth
    );
    (
        getPathLength(Board,ToVisit,[],_,Allied,Color,Depth,ReturnVal),
        ReturnVal,
        write('Returned true:'),
        write(Depth),
        Length is Depth
    );
    (
        NewDepth is Depth+1,
        !,getPathLengthWrapper(Board,ToVisit,[],Allied,Color,NewDepth,Length)
    ).

memberWithDepth([Row,Diag,Depth],[[Row,Diag,Depth2]|_]):-Depth=<Depth2.
memberWithDepth(X,[_|T]) :- memberWithDepth(X,T).

getPathLength(_,[],Visited,Visited,_,_,_,false).
getPathLength(_,_,Visited,Visited,_,_,-1,false).
getPathLength(Board,ToVisit,Visited,NewVisited,Allied,CheckingColor,Depth,ReturnVal):-
    
    ((CheckingColor == orange,write(ToVisit), nl);true),
    
    (
        (member([18,12],ToVisit),write([18,12]));
        (member([19,12],ToVisit),write([19,12]));
        (member([20,12],ToVisit),write([18,12]));
        (member([21,12],ToVisit),write([18,12]));
        (member([22,12],ToVisit),write([18,12]));
        true
    ),
    %trace,
    [H|T] = ToVisit,
    (
        
        (
            [Row,Diagonal | _ ] = H,
            \+memberWithDepth([Row,Diagonal,Depth],Visited),
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Row,Color),
            (
                (
                    (Color == CheckingColor; Color == Allied),
                    (
                        (at_border(CheckingColor, Row, Diagonal), ReturnVal = true,write('At border'));
                        (
                            getNeighbours(Row, Diagonal, Neighbours),
                            !,
                            (
                                getPathLength(Board,Neighbours,[[Row,Diagonal,Depth] | Visited],NewVisited,Allied,CheckingColor,Depth,NewReturnVal),
                                (
                                    (NewReturnVal, ReturnVal = true); 
                                    !,(getPathLength(Board,T,[[Row,Diagonal,Depth] | NewVisited],_,Allied,CheckingColor,Depth, ReturnVal), ReturnVal)
                                )
                            )
                        )
                    )
                );
                (
                    Color == empty,
                    (
                        (at_border(CheckingColor, Row, Diagonal), ReturnVal = true,write('At border'));
                        (
                            getNeighbours(Row, Diagonal, Neighbours),
                            AuxDepth is Depth-1,
                            !,
                            (
                                getPathLength(Board,Neighbours,[[Row,Diagonal,Depth] | Visited],NewVisited,Allied,CheckingColor,AuxDepth,NewReturnVal),
                                (
                                    (NewReturnVal, ReturnVal = true); 
                                    !,(getPathLength(Board,T,[[Row,Diagonal,Depth] | NewVisited],_,Allied,CheckingColor,Depth, ReturnVal),ReturnVal)
                                )
                            )
                        )
                    )
                )
            )
        );
        (
            [Row,Diagonal | _ ] = H,
            !,getPathLength(Board,T,[[Row,Diagonal,Depth] | Visited],_,Allied,CheckingColor,Depth,ReturnVal), NewVisited = Visited
        )
    ).


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
    
    