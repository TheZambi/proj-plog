:- include('display.pl').
:- include('input.pl').
:- include('bot.pl').

:- use_module(library(random)).
:- use_module(library(aggregate)).
:- use_module(library(system)).

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

at_border(purple, 0, 1).
at_border(purple, 1, 2).
at_border(purple, 2, 3).
at_border(purple, 3, 4).
at_border(purple, 4, 5).

at_border(green, 7, 7).
at_border(green, 9, 8).
at_border(green, 11, 9).
at_border(green, 13, 10).
at_border(green, 15, 11).


update_player(Player, NewPlayer):-
    NewPlayer is mod(Player+1,2).


getValue(Board,RowNumber,Diagonal,Color):-
    nth0(RowNumber,Board,Row),
    diagonal_index(RowNumber,DiagonalStart),
    DiagonalDiff is Diagonal-DiagonalStart,
    nth0(DiagonalDiff,Row,Color).


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

move(GameState, Move, NewGameState):-
    [Board | T ] = GameState,
    [RowNumber|_] = Move,
    getRow(Board,RowNumber,NewBoard,Move),
    NewGameState = [NewBoard|T].

count_occurrences(List, X, Count) :- aggregate_all(count, member(X, List), Count).

game_over(GameState, Winner):-
    [ _ , ColorsWon | _ ] = GameState, 
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
    Neighbours = [[LastRow,Diagonal],[NextRow,NextDiagonal],[LastLastRow,LastDiagonal],[NextNextRow,NextDiagonal],[LastRow,LastDiagonal],[NextRow,Diagonal]].
    

checkOrange(Board,PlayerOrange, Player):-
    ToVisit = [[0,0],[1,0],[2,0],[3,0],[4,0]] ,
    (
        (
            allied(0,orange,Allied0),
            (
                (
                    checkLine(Board,ToVisit,[],Allied0,orange,0), 
                    Player0Orange is 0
                );
                (
                    (
                        \+checkLine(Board,ToVisit,[],Allied0,orange,1),
                        Player1Orange is 1
                    )
                );  
                true
            )
        ),
        (
            allied(1,orange,Allied1),
            (
                (
                    \+number(Player1Orange),
                    checkLine(Board,ToVisit,[],Allied1,orange,0),
                    Player1Orange is 1
                ); 
                (
                    \+number(Player0Orange),
                    (
                        \+checkLine(Board,ToVisit,[],Allied1,orange,1),
                        Player0Orange is 0
                    )
                );
                true
            )
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
    ToVisit = [[7,1],[9,2],[11,3],[13,4],[15,5]] ,
    (
        (
            allied(0,green,Allied0),
            (
                (
                    checkLine(Board,ToVisit,[],Allied0,green,0), 
                    Player0Green is 0

                );
                (
                    (
                        \+checkLine(Board,ToVisit,[],Allied0,green,1),
                        Player1Green is 1
                    )
                );  
                true
            )
        ),
        (
            allied(1,green,Allied1),
            (
                (
                    \+number(Player1Green),
                    checkLine(Board,ToVisit,[],Allied1,green,0),
                    Player1Green is 1
                ); 
                (
                    \+number(Player0Green),
                    (
                        \+checkLine(Board,ToVisit,[],Allied1,green,1),
                        Player0Green is 0
                    )
                );
                true
            )
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
    ToVisit = [[18,7],[19,8],[20,9],[21,10],[22,11]],
    (
        (
            allied(0,purple,Allied0),
            (
                (
                    checkLine(Board,ToVisit,[],Allied0,purple,0), 
                    Player0Purple is 0
                );
                (
                    (
                        \+checkLine(Board,ToVisit,[],Allied0,purple,1),
                        Player1Purple is 1
                    )
                );  
                true
            )
        ),
        (
            allied(1,purple,Allied1),
            (
                (
                    \+number(Player1Purple),
                    checkLine(Board,ToVisit,[],Allied1,purple,0),
                    Player1Purple is 1
                ); 
                (
                    \+number(Player0Purple),
                    (
                        \+checkLine(Board,ToVisit,[],Allied1,purple,1),
                        Player0Purple is 0
                    )
                );
                true
            )
        )
    ),
    (
        (
            number(Player0Purple), number(Player1Purple),
            PlayerPurple is Player
        );
        (
            number(Player0Purple),
            PlayerPurple is Player0Purple
        );
        (
            number(Player1Purple),
            PlayerPurple is Player1Purple
        ); fail
    ).


checkLine(_,[],_,_,_,_):- fail.

checkLine(Board,ToVisit,Visited,Allied,CheckingColor, Fencing):-
    [H|T] = ToVisit,
    (
        
        (
            \+member(H,Visited),
            [Row,Diagonal | _ ] = H,
            valid_line(Row),
            diagonal_index(Row,D1),
            diagonal_index_end(Row,D2),
            valid_diagonal(Diagonal,D1,D2),
            getValue(Board,Row,Diagonal,Color),
            (Color == CheckingColor; Color == Allied; (Fencing =:= 1, Color == empty)),
            (
                at_border(CheckingColor, Row, Diagonal);
                (
                    getNeighbours(Row, Diagonal, Neighbours),
                    append(Neighbours,T,NewToVisit),
                    !,checkLine(Board,NewToVisit,[H | Visited],Allied,CheckingColor,Fencing)
                )
            )
        );
        (
            !,checkLine(Board,T,[H | Visited],Allied,CheckingColor,Fencing)
        )
    ).



updateColorsWon(GameState,NewColorsWon, Player):-
    [Board, ColorsWon | _ ] = GameState,
    [OrangeWon, PurpleWon, GreenWon | _ ] = ColorsWon,
    (
        (
            (OrangeWon =:= -1),
            checkOrange(Board,PlayerOrange, Player)
        );
        (
            PlayerOrange = OrangeWon
        )
    ),
    (
        (
            (PurpleWon =:= -1),
            checkPurple(Board, PlayerPurple, Player)
        );
        (
            PlayerPurple = PurpleWon
        )
    ),
    (
        (
            (GreenWon =:= -1),
            checkGreen(Board,PlayerGreen,Player)
        );
        (
            PlayerGreen = GreenWon
        )
    ),
    NewColorsWon = [PlayerOrange, PlayerPurple, PlayerGreen].

updateNPieces(Move,NPieces,NewNPieces):-
    [_,_,Color|_] = Move,
    [OrangePieces, PurplePieces, GreenPieces | _] = NPieces,
    (
        (
            (Color == orange),
            O is OrangePieces-1,
            NewNPieces = [O,PurplePieces,GreenPieces]
        );
        (
            (Color == purple),
            P is PurplePieces-1,
            NewNPieces = [OrangePieces,P,GreenPieces]
        );
        (
            (Color == green),
            G is GreenPieces-1,
            NewNPieces = [OrangePieces,PurplePieces,G]
        )
    ).


game_loop(GameState,Player,Winner,1,_,_):-  %PvP  (1)
    [Board | T] = GameState,
    [ColorsWon , NPieces | _] = T,
    display_game(GameState,Player),
    get_move(Move,Board, NPieces),
    updateNPieces(Move,NPieces,NewNPieces),
    move(GameState, Move, NewGameState),
    [NewBoard | _] = NewGameState,
    updateColorsWon([NewBoard, ColorsWon], NewColorsWon, Player),
    !,
    game_over([NewBoard,NewColorsWon,NewNPieces],Winner),
    update_player(Player, NewPlayer),
    (
       (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewColorsWon,NewNPieces],NewPlayer,Winner,1,_,_)
        )
    ).


      
game_loop(GameState,Player,Winner,2,Level,_):- %PvAI  (2)
    [Board | T] = GameState,
    [ColorsWon , NPieces | _] = T,
    display_game(GameState,Player),
    (
        (
            Player =:= 0,
            get_move(Move,Board, NPieces)
        );
        (
            choose_move(GameState,Player,Level,Move)
        )
    ),
    updateNPieces(Move,NPieces,NewNPieces),
    move(GameState, Move, NewGameState),    
    [NewBoard | _] = NewGameState,
    updateColorsWon([NewBoard, ColorsWon], NewColorsWon, Player),
    !,
    game_over([NewBoard,NewColorsWon,NewNPieces],Winner),
    update_player(Player, NewPlayer),
    (
       (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewColorsWon,NewNPieces],NewPlayer,Winner,2,Level,_)
        )
    ).

game_loop(GameState,Player,Winner,3,Level,_):- %AIvP  (3)
    [Board | T] = GameState,
    [ColorsWon , NPieces | _] = T,
    display_game(GameState,Player),
    (
        (
            Player =:= 1,
            get_move(Move,Board, NPieces)
        );
        (
            choose_move(GameState,Player,Level,Move)
        )
    ),
    updateNPieces(Move,NPieces,NewNPieces),
    move(GameState, Move, NewGameState),    
    [NewBoard | _] = NewGameState,
    updateColorsWon([NewBoard, ColorsWon], NewColorsWon, Player),
    !,
    game_over([NewBoard,NewColorsWon,NewNPieces],Winner),
    update_player(Player, NewPlayer),
    (
       (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewColorsWon,NewNPieces],NewPlayer,Winner,3,Level,_)
        )
    ).

game_loop(GameState,Player,Winner,4,Level1,Level2):- %AIvAI  (4)
    [_ | T] = GameState,
    [ColorsWon , NPieces | _] = T,
    display_game(GameState,Player),
    (
        (
            Player =:= 1,
            choose_move(GameState,Player,Level2,Move)
        );
        (
            choose_move(GameState,Player,Level1,Move)
        )
    ),
    updateNPieces(Move,NPieces,NewNPieces),
    move(GameState, Move, NewGameState),    
    [NewBoard | _] = NewGameState,
    updateColorsWon([NewBoard, ColorsWon], NewColorsWon, Player),
    !,
    game_over([NewBoard,NewColorsWon,NewNPieces],Winner),
    update_player(Player, NewPlayer),
    (
       (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewColorsWon,NewNPieces],NewPlayer,Winner,4,Level1,Level2)
        )
    ).


get_bot_dificulty(1,_, _):- !.
get_bot_dificulty(4, Difficulty1, Difficulty2):- 
    !,
    repeat,
        write('         Difficulty for BOT 1:'), nl,
        write('         1) Easy'), nl,
        write('         2) Medium'), nl,
        read(AuxDifficulty1),
        number(AuxDifficulty1),
        between(1,2,AuxDifficulty1), !,
    repeat,
        write('         Difficulty for BOT 2:'), nl,
        write('         1) Easy'), nl,
        write('         2) Medium'), nl,
        read(AuxDifficulty2),
        number(AuxDifficulty2),
        between(1,2,AuxDifficulty2), !,
    Difficulty1 = AuxDifficulty1,
    Difficulty2 = AuxDifficulty2.

get_bot_dificulty(_, Difficulty1, _):- 
    !,
    repeat,
        write('         Difficulty for the BOT:'), nl,
        write('         1) Easy'), nl,
        write('         2) Medium'), nl,
        read(AuxDifficulty1),
        number(AuxDifficulty1),
        between(1,2,AuxDifficulty1), !,
    Difficulty1 = AuxDifficulty1.

play :-
    prompt(_,''),
    display_name,
    display_mode(Mode),
    get_bot_dificulty(Mode, Difficulty1, Difficulty2),
    player(Player),
    initial(Board),
    game_loop([Board,[-1,-1,-1],[42,42,42]], Player, Winner, Mode, Difficulty1, Difficulty2),
    display_winner(Winner).

