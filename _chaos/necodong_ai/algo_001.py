def think(hands, history, old_games):
    if len(hands) == 5:
        return '1'
    if len(hands) == 4:
        return '5'
    if len(hands) == 3:
        return '4'
    if len(hands) == 2:
        return '3'
    if len(hands) == 1:
        return '2'
