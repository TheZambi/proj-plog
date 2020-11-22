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

valid_moves(GameState, _,FinalListOfMoves):-
    [Board, _ , NPieces] = GameState,
    iterateBoard(Board,NPieces,0,_, AuxFinalListOfMoves),
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
    write(AuxValue),write(AuxValue1),write(AuxValue2),
    PathValue is AuxValue + AuxValue1 + AuxValue2.
 
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
        getPathLength(Board,ToVisit,[],Allied,Color,Depth),
        Length is Depth
    );
    (
        NewDepth is Depth+1,
        getPathLengthWrapper(Board,ToVisit,[],Allied,Color,NewDepth,Length)
    ).

getPathLength(_,[],_,_,_,_):- fail.
getPathLength(Board,ToVisit,Visited,Allied,CheckingColor,Depth):-
    Depth > 0,
    [H|T] = ToVisit,
    (
        
        (
            \+member(H,Visited),
            [Row,Diagonal | _ ] = H,
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Row,Color),
            (
                (
                    (Color == CheckingColor; Color == Allied),
                    (
                        at_border(CheckingColor, Row, Diagonal);
                        (
                            getNeighbours(Row, Diagonal, Neighbours),
                            !,
                            (
                                getPathLength(Board,Neighbours,[H | Visited],Allied,CheckingColor,Depth);
                                getPathLength(Board,T,[H | Visited],Allied,CheckingColor,Depth)
                            )
                        )
                    )
                );
                (
                    Color == empty,
                    (
                        at_border(CheckingColor, Row, Diagonal);
                        (
                            getNeighbours(Row, Diagonal, Neighbours),
                            AuxDepth is Depth-1,
                            !,
                            (
                                getPathLength(Board,Neighbours,[H | Visited],Allied,CheckingColor,AuxDepth);
                                getPathLength(Board,T,[H | Visited],Allied,CheckingColor,Depth)
                            )
                        )
                    )
                )
            )
            
        );
        (
            !,getPathLength(Board,T,[H | Visited],Allied,CheckingColor,Depth)
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
    UpperBound is Length+1,
    random(0,UpperBound,RandomMove),
    get_random_move(ListOfMoves,RandomMove,Move).
