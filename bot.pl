value(GameState, Value):-
    [Board, ColorsWon | _] = GameState,
    captured_color_value(ColorsWon, ColorValue),
    Value is ColorValue.

captured_color_value(ColorsWon,ColorValue):-
    count_occurrences(ColorsWon,0,CountOfZero),
    count_occurrences(ColorsWon,1,CountOfOne),
    AuxValue is 0 + CountOfZero * 50,
    ColorValue is AuxValue - (CountOfOne * 50).