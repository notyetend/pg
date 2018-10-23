def think(hands, history, old_games):
    def get_hand_with_pattern(pattern):
        return pattern[5-len(hands)]

    def get_defence_pattern_continuing(pattern):
        rt = ''
        for p in pattern:
            rt += str(int(p) % 5 + 1)
        return rt

    if len(old_games) == 0:
        return get_hand_with_pattern('15432')
    else:
        last_game = old_games[-1]
        pattern = ''
        for game in last_game:
            pattern += game[1]

        continuing_defence_pattern = get_defence_pattern_continuing(pattern)
        return get_hand_with_pattern(continuing_defence_pattern)

