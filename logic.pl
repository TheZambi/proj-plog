:- include('display.pl').
:- include('input.pl').

:- dynamic player/1.

player(1).


allied(0,orange,green).
allied(0,green,purple).
allied(0,purple,orange).
allied(1,orange,purple).
allied(1,green,orange).
allied(1,purple,green).


update_player(Player):-
    P is mod(Player+1,2),
    retract(player(_)),
    assert(player(P)).

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
    NewRowNumber is RowNumber-1,
    getRow(T,NewRowNumber,NewBoard,Move).

move(Board, Move, NewBoard):-
    [RowNumber|_] = Move,
    getRow(Board,RowNumber,NewBoard,Move).

game_over(Winner,Player1Colors,Player2Colors):-
    length(Player1Colors,Player1Length),
    length(Player2Colors,Player2Length),
    (Player1Length < 2 ; Winner is 0),
    (Player2Length < 2 ; Winner is 1).

updateColorsWon(GameState,NewPlayer1Colors,NewPlayer2Colors):-
    [Board, Player1Colors, Player2Colors | _ ] = GameState,
    (
        (
            \+member(orange, Player1Colors), 
            \+member(orange, Player2Colors),
            checkOrange(Board,PlayerOrange)
        );
        (
            \+member(purple, Player1Colors), 
            \+member(purple, Player2Colors),
            checkPurple(Board,PlayerPurple)
        );
        (
            \+member(green, Player1Colors), 
            \+member(green, Player2Colors),
            checkGreen(Board,PlayerGreen)
        );
        (
            true
        )
    ),
    (
        number(PlayerOrange),
        PlayerOrange==0,
        append(Player1Colors,orange,AuxOrange),
        Player1Colors = AuxOrange

    ).


game_loop(GameState,Player,Winner):-
    [Board | ColorsWon] = GameState,
    display_game(Board,Player),
    get_move(Move,Board),
    move(Board, Move, NewBoard),
    updateColorsWon([NewBoard | ColorsWon],NewPlayer1Colors,NewPlayer2Colors),
    !,
    game_over(Winner,NewPlayer1Colors,NewPlayer2Colors),
    update_player(Player),
    (
        (
            number(Winner)  % in case there is a winner already the game loop is finished
        );
        (
            game_loop([NewBoard,NewPlayer1Colors,NewPlayer2Colors],Player,Winner)
        )
    ).
      

play :-
    prompt(_,''),
    player(Player),
    initial(Board),
    game_loop([Board,[],[]],Player,Winner).




plzwork :-
    Test = [1,2,3],
    write(Test),
    append(Test,[4],Nigger),
    write(Nigger),
    Test = Nigger,
    write(Nigger).
    write(Test).