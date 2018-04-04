def think(hands, history, old_games):
    import random

    def random_choice(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    def pattern_shuffle(pattern):
        return pattern[-1] + pattern[1:-1] + pattern[0]

    def get_hand_with_pattern(pattern):
        return pattern[5-len(hands)]

    def get_defence_pattern_continuing(pattern):
        rt = ''
        for p in pattern:
            rt += str(int(p) % 5 + 1)
        return rt

    debug = False
    num_round = len(history) + 1
    num_match = len(old_games) + 1

    if debug:
        print('Hands', hands)
        print('History:', history)
        print('Old games:', old_games)
        print('Round no:', num_round)
        print('Match no:', num_match)

    if num_match == 1:
        return get_hand_with_pattern('15432')
    else:
        if debug:
            print('-->', old_games[-1])
        last_game = old_games[-1]
        pattern = ''
        for game in last_game:
            pattern += game[1]

        if debug:
            print('Pattern', pattern)

        continuing_defence_pattern = get_defence_pattern_continuing(pattern)
        continuing_defence_pattern = pattern_shuffle(continuing_defence_pattern)
        return get_hand_with_pattern(continuing_defence_pattern)

