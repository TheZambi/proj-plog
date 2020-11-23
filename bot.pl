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
    AuxValue is 0 + CountOfPlayer * 400,
    ColorValue is AuxValue - (CountOfOpponent * 400).

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
        (Orange \== -1, Length is 9) ; 
        getOrangePathLength(Player,Board,Length)
    ),
    (
        (Purple \==  -1, Length1 is 9);
        getPurplePathLength(Player,Board,Length1)
    ),
    (
        (Green \==  -1, Length2 is 9); 
        getGreenPathLength(Player,Board,Length2)
    ),
    AuxValue is (9-Length)*(9-Length)*(9-Length),
    AuxValue1 is (9-Length1)*(9-Length1)*(9-Length1),
    AuxValue2 is (9-Length2)*(9-Length2)*(9-Length2),
    PathValue is AuxValue + AuxValue1 + AuxValue2.

getOrangePathLength(Player,Board,Length):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]],
    allied(Player,orange,Allied),
    getPathLength(Board,ToVisit,[],Allied,orange,1,Length).


getPurplePathLength(Player,Board,Length):-
    ToVisit = [[18,7],[19,8],[20,9],[21,10],[22,11]],
    allied(Player,purple,Allied),
    getPathLength(Board,ToVisit,[],Allied,purple,1,Length).

getGreenPathLength(Player,Board,Length):-
    ToVisit = [[7,1],[9,2],[11,3],[13,4],[15,5]],
    allied(Player,green,Allied),
    getPathLength(Board,ToVisit,[],Allied,green,1,Length).
    

buildLevel(_,Level1,Level1,[],Visited,Visited,_,_).
buildLevel(Board,Level1,ReturnLevel,ToVisit,Visited,NewVisited,Allied,CheckingColor):-
    [H|T] = ToVisit,
    [Row,Diagonal | _] = H,
    (
        (
            \+member(H,Visited),
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Color),
            (
                (
                    (Color == Allied; Color == CheckingColor),
                    getNeighbours(Row,Diagonal,Neighbours),
                    append(Neighbours,T,Aux),
                    append([H],Visited,Aux2),
                    remove_dups(Aux,NoDupes),
                    buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,NewVisited,Allied,CheckingColor)
                );
                (
                    (Color == empty),
                    append([H],Visited,Aux2),
                    remove_dups(T,NoDupes),
                    buildLevel(Board,[H|Level1],ReturnLevel,NoDupes,Aux2,NewVisited,Allied,CheckingColor)
                );
                (
                    getNeighbours(Row,Diagonal,Neighbours),
                    append(Neighbours,T,Aux),
                    append([H],Visited,Aux2),
                    remove_dups(Aux,NoDupes),
                    buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,NewVisited,Allied,CheckingColor)
                )
            )
        ); 
        (
            append([H],Visited,Aux2),
            remove_dups(T,NoDupes),
            buildLevel(Board,Level1,ReturnLevel,NoDupes,Aux2,NewVisited,Allied,CheckingColor)
        )
    ).

getNextPossibleVisited([], ToVisitNext,ToVisitNext).
getNextPossibleVisited(ReturnLevel, Aux,ToVisitNext):-
    [H|T] = ReturnLevel,
    [Row,Diagonal | _ ] = H,
    getNeighbours(Row,Diagonal,Neighbours),
    append(Neighbours,Aux,NewToVisit),
    getNextPossibleVisited(T,NewToVisit, ToVisitNext).
    
fillFinishLevel(_,[],_,NewLevel,NewLevel,_,_).
fillFinishLevel(Board,ToVisitNext,Visited,Aux,NewLevel,CheckingColor,Allied):-
    [H | T] = ToVisitNext,
    [Row,Diagonal | _] = H,
    (
        (
            \+member(H,Visited),
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Color),
            (Color == CheckingColor; Color == Allied), 
            getNeighbours(Row,Diagonal,Neighbours),
            fillFinishLevel(Board,[Neighbours | ToVisitNext], [H | Visited], [H | Aux], NewLevel,CheckingColor,Allied)

        );
        (
            fillFinishLevel(Board,T,Visited,Aux,NewLevel,CheckingColor,Allied)
        )
    ).


stopCondition(orange,NewLevel):-
(
    (member([18,12],NewLevel));
    (member([19,12],NewLevel));
    (member([20,12],NewLevel));
    (member([21,12],NewLevel));
    (member([22,12],NewLevel))
).


stopCondition(purple,NewLevel):-
(
    (member([0,1],NewLevel));
    (member([1,2],NewLevel));
    (member([2,3],NewLevel));
    (member([3,4],NewLevel));
    (member([4,5],NewLevel))
).

stopCondition(green,NewLevel):-
(
    (member([7,7],NewLevel));
    (member([9,8],NewLevel));
    (member([11,9],NewLevel));
    (member([13,10],NewLevel));
    (member([15,11],NewLevel))
).

remove_list([], _, []).
remove_list([X|Tail], L2, Result):- member(X, L2), !, remove_list(Tail, L2, Result). 
remove_list([X|Tail], L2, [X|Result]):- remove_list(Tail, L2, Result).

getPathLength(Board,ToVisit,LastVisited,Allied,CheckingColor,CurrentDepth,Depth):-
    buildLevel(Board,[],ReturnLevel,ToVisit,LastVisited,Visited,Allied,CheckingColor),
    getNextPossibleVisited(ReturnLevel, [],ToVisitNext),
    fillFinishLevel(Board,ToVisitNext,Visited,[],NewLevel,CheckingColor,Allied),
    NewDepth is CurrentDepth+1,
    append(ReturnLevel,NewLevel,FinishedLevel),
    append(Visited,NewLevel,NewVisited),
    getNextPossibleVisited(FinishedLevel,[],NewToVisitNext),
    remove_list(NewToVisitNext,NewVisited,NextListOfTiles),
    (
        (
            \+stopCondition(CheckingColor,FinishedLevel),
            getPathLength(Board,NextListOfTiles,NewVisited,Allied,CheckingColor,NewDepth,Depth)
        );
        (
            !,Depth is CurrentDepth
        )
    ).

choose_move(GameState,Player,1,Move):- 
    valid_moves(GameState,Player, ListOfMoves),
    length(ListOfMoves,Length),
    random(0,Length,RandomMove),
    nth0(RandomMove,ListOfMoves,Move), sleep(1),
    [Row,Diagonal,Color] = Move,
    write('Putting piece of color '), write(Color), write(' at row '), write(Row), write(' and diagonal '), write(Diagonal), nl.

choose_move(GameState,Player,2,Move):- 
    valid_moves(GameState,Player, ListOfMoves),
    simMoves(GameState,ListOfMoves,Player,_BestMove,-10000, NewMove),
    length(NewMove,Length),
    random(0,Length,RandomMove),
    nth0(RandomMove,NewMove,Move),
    [Row,Diagonal,Color] = Move,
    write('Putting piece of color '), write(Color), write(' at row '), write(Row), write(' and diagonal '), write(Diagonal), nl.

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
            simMoves(GameState,T,Player,[Move],Value,FinalBestMove)
        ); 
        (
            Value =:= BestMoveValue,
            simMoves(GameState,T,Player,[Move | BestMove],BestMoveValue,FinalBestMove)
        ); 
        simMoves(GameState,T,Player,BestMove,BestMoveValue,FinalBestMove)
    ).
    