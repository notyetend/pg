def think(hands, history, old_games):
    import random

    def random_choice(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    def get_hand_with_pattern(pattern):
        return pattern[5-len(hands)]

    def get_defence_pattern_continuing(pattern):
        rt = ''
        for p in pattern:
            rt += str(int(p) % 5 + 1)
        return rt

    if len(old_games) < 2:
        return random_choice(hands)
    else:
        last_game = old_games[-1]
        pattern = ''
        for game in last_game:
            pattern += game[1]

        continuing_defence_pattern = get_defence_pattern_continuing(pattern)
        return get_hand_with_pattern(continuing_defence_pattern)

