value(GameState, Player, Value):-
    [Board, ColorsWon | _] = GameState,
    captured_color_value(ColorsWon, ColorValue),
    getPathValue(Board,PathValue),
    Value is ColorValue + PathValue.

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

valid_moves(GameState, Player,FinalListOfMoves):-
    [Board, _ , NPieces] = GameState,
    iterateBoard(Board,NPieces,0,AuxListOfMoves, AuxFinalListOfMoves),
    remove_dups(AuxFinalListOfMoves, NoDuplicateListOfMoves),
    delete(NoDuplicateListOfMoves,[], FinalListOfMoves).

getPathValue(Board,PathValue):-
    getOrangePathLength(Board,Length),
    getPurplePathLength(Board,Length1),
    getGreenPathLength(Board,Length2),
    AuxValue is (5-Length)*4,
    AuxValue1 is (5-Length1)*4,
    AuxValue2 is (5-Length2)*4,
    PathValue is AuxValue + AuxValue1 + AuxValue2.
 
getOrangePathLength(Board,Length):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]],
    allied(0,orange,Allied),
    getPathLengthWrapper(Board,ToVisit,[],Allied,orange,1,Length).

getPurplePathLength(Board,Length):-
    ToVisit = [[0,1],[1,2],[2,3],[3,4],[4,5]],
    allied(0,purple,Allied),
    getPathLengthWrapper(Board,ToVisit,[],Allied,purple,1,Length).

getGreenPathLength(Board,Length):-
    ToVisit = [[7,7],[9,8],[11,9],[13,10],[15,11]],
    allied(0,green,Allied),
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

