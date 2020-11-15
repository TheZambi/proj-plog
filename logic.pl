:- include('display.pl').
:- include('input.pl').

:- use_module(library(aggregate)).

:- dynamic player/1.

player(0).


allied(0,orange,green).
allied(1,orange,purple).

allied(0,green,purple).
allied(1,green,orange).

allied(0,purple,orange).
allied(1,purple,green).

at_border(orange, 18, 12).
at_border(orange, 19, 12).
at_border(orange, 20, 12).
at_border(orange, 21, 12).
at_border(orange, 22, 12).

at_border(purple, 18, 7).
at_border(purple, 19, 8).
at_border(purple, 20, 9).
at_border(purple, 21, 10).
at_border(purple, 22, 11).

at_border(green, 7, 1).
at_border(green, 9, 2).
at_border(green, 11, 3).
at_border(green, 13, 4).
at_border(green, 15, 5).


update_player(Player, NewPlayer):-
    NewPlayer is mod(Player+1,2).


getValue([Row|_],0,Diagonal,InitialRow,Color):-
    diagonal_index(InitialRow,X),
    IndexInRow is Diagonal-X,
    nth0(IndexInRow,Row,Color).

getValue([_|T],RowNumber,Diagonal,InitialRow,Color):-
    RowNumber > 0,
    NewRowNumber is RowNumber-1,
    getValue(T,NewRowNumber,Diagonal,InitialRow,Color).


% gotten from https://stackoverflow.com/questions/8519203/prolog-replace-an-element-in-a-list-at-a-specified-index/8544713
replace_val([_|T], 0, X, [X|T]).
replace_val([H|T], I, X, [H|R]):- 
  I > 0, 
  I1 is I-1, 
  replace_val(T, I1, X, R).

getRow([Row|T],0,[NewRow|T],Move):-
    [InitialRow|V] = Move,
    [Diagonal|R] = V,
    diagonal_index(InitialRow,X),
    Replace is Diagonal-X,
    [Color|_] = R,
    replace_val(Row,Replace,Color,NewRow).

getRow([H|T],RowNumber,[H|NewBoard],Move):-
    RowNumber > 0,
    NewRowNumber is RowNumber-1,
    getRow(T,NewRowNumber,NewBoard,Move).

move(Board, Move, NewBoard):-
    [RowNumber|_] = Move,
    getRow(Board,RowNumber,NewBoard,Move).

count_occurrences(List, X, Count) :- aggregate_all(count, member(X, List), Count).

game_over(Winner,ColorsWon):-
    count_occurrences(ColorsWon,0,CountOfZero),
    count_occurrences(ColorsWon,1,CountOfOne),
    (CountOfZero < 2 ; Winner is 0),
    (CountOfOne < 2 ; Winner is 1).

valid_line(Line):-
    number(Line),
    Line >= 0,
    Line =< 22.
  
valid_diagonal(Diagonal, D1, D2):-
    number(Diagonal),
    Diagonal >= D1,
    Diagonal =< D2.
    

getNeighbours(Row,Diagonal,Neighbours):-
    valid_line(Row),
    diagonal_index(Row,DiagonalStart), 
    diagonal_index_end(Row,DiagonalEnd), 
    valid_diagonal(Diagonal,DiagonalStart,DiagonalEnd),
    LastRow is Row-1,
    LastLastRow is Row-2,
    NextRow is Row+1,
    NextNextRow is Row+2,
    LastDiagonal is Diagonal-1,
    NextDiagonal is Diagonal+1,
    Neighbours = [[LastRow,LastDiagonal],[LastLastRow,LastDiagonal],[LastRow,Diagonal],[NextRow,Diagonal],[NextRow,NextDiagonal],[NextNextRow,NextDiagonal]].
    

checkOrange(Board,PlayerOrange, Player):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]] ,
    (
        (
            (
                allied(0,orange,Allied0),
                checkLine(Board,ToVisit,[],Allied0,orange),
                Player0Orange is 0
            ); true
        );
        (
            (
                allied(1,orange,Allied1),
                checkLine(Board,ToVisit,[],Allied1,orange),
                Player1Orange is 1
            ); true
        )
    ),
    (
        (
            number(Player0Orange), number(Player1Orange),
            PlayerOrange is Player
        );
        (
            number(Player0Orange),
            PlayerOrange is Player0Orange
        );
        (
            number(Player1Orange),
            PlayerOrange is Player1Orange
        ); fail
    ).
    
checkGreen(Board,PlayerGreen, Player):-
    ToVisit = [[7,7],[9,8],[11,9],[13,10],[15,11]] ,
    (
        (
            (
                allied(0,green,Allied0),
                checkLine(Board,ToVisit,[],Allied0,green),
                Player0Green is 0
            );  true
        ),
        (
            (
                allied(1,green,Allied1),
                checkLine(Board,ToVisit,[],Allied1,green),
                Player1Green is 1
            ); true
        )
    ),
    (
        (
            number(Player0Green), number(Player1Green),
            PlayerGreen is Player
        );
        (
            number(Player0Green),
            PlayerGreen is Player0Green
        );
        (
            number(Player1Green),
            PlayerGreen is Player1Green
        ); fail
    ).

checkPurple(Board,PlayerPurple, Player):-
    ToVisit = [[0,1],[1,2],[2,3],[3,4],[4,5]] ,
    (
        (
            (
                allied(0,purple,Allied0),
                checkLine(Board,ToVisit,[],Allied0,purple),
                Player0Purple is 0
            );  true
        ),
        (
            (
                allied(1,purple,Allied1),
                checkLine(Board,ToVisit,[],Allied1,purple),
                Player1Purple is 1
            ); true
        )
    ),
    (
        (
            number(Player0Purple), number(Player1Purple),
            P is Player+1,
            write('Player '), write(P),
            PlayerPurple is Player
        );
        (
            number(Player0Purple),
            write('Player 1'),
            PlayerPurple is Player0Purple
        );
        (
            number(Player1Purple),
            write('Player 2'),
            PlayerPurple is Player1Purple
        ); fail
    ).


checkLine(_,[],_,_,_):- fail.

checkLine(Board,ToVisit,Visited,Allied,CheckingColor):-
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
            (Color == CheckingColor; Color == Allied),
            (
                at_border(CheckingColor, Row, Diagonal);
                (
                    getNeighbours(Row, Diagonal, Neighbours),
                    append(Neighbours,T,NewToVisit),
                    checkLine(Board,NewToVisit,[H | Visited],Allied,CheckingColor)
                )
            )
        );
        (
            checkLine(Board,T,[H | Visited],Allied,CheckingColor)
        )
    ).



updateColorsWon(GameState,NewColorsWon, Player):-
    [Board, ColorsWon | _ ] = GameState,
    [OrangeWon, PurpleWon, GreenWon | _ ] = ColorsWon,
    (
        (
            (OrangeWon == -1),
            checkOrange(Board,PlayerOrange, Player)
        );
        (
            PlayerOrange = OrangeWon
        )
    ),
    (
        (
            (PurpleWon == -1),
            checkPurple(Board, PlayerPurple, Player)
        );
        (
            PlayerPurple = PurpleWon
        )
    ),
    (
        (
            (GreenWon == -1),
            checkGreen(Board,PlayerGreen,Player)
        );
        (
            PlayerGreen = GreenWon
        )
    ),
    NewColorsWon = [PlayerOrange, PlayerPurple, PlayerGreen].


game_loop(GameState,Player,Winner):-
    [Board | ColorsWon] = GameState,
    display_game(Board,Player),
    get_move(Move,Board),
    move(Board, Move, NewBoard),
    updateColorsWon([NewBoard | ColorsWon],NewColorsWon, Player),
    !,
    game_over(Winner,NewColorsWon),
    update_player(Player, NewPlayer),
    (
        (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewColorsWon],NewPlayer,Winner)
        )
    ).
      

play :-
    prompt(_,''),
    player(Player),
    initial(Board),
    game_loop([Board,[-1,-1,-1]],Player,Winner),
    display_winner(Winner).