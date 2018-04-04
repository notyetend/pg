def think(hands, history, old_games):
    import random

    debug = False
    full_hands = ['1', '2', '3', '4', '5']

    def random_choice(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    def get_hand_with_pattern(pattern):
        return pattern[5-len(hands)]

    def get_defence_pattern_continuing(pattern):
        rt = ''
        for p in pattern:
            rt += str(int(p) % 5 + 1)
        return rt

    def get_your_hands():
        return list(set(full_hands).difference({h[1] for h in history}))

    def one_round(my, your):
        if my == your:
            return 0
        elif my == '1' and your == '5':
            return 1
        elif my == '5' and your == '1':
            return -1
        else:
            if my > your:
                return 1
            else:
                return -1

    def get_max_actions():
        your_hands = get_your_hands()
        av = {h:0 for h in hands}
        for my in hands:
            for your in your_hands:
                result = one_round(my, your)
                if result == 1:
                    av[my] += 1
                elif result == -1:
                    av[my] -= 1
                else:
                    pass
        max_val = max(av.values())
        return [k for k, v in av.items() if v == max_val]

    if len(old_games) < 2:
        return random_choice(hands)
    elif len(hands) >= 4:
        last_game = old_games[-1]
        pattern = ''
        for game in last_game:
            pattern += game[1]

        continuing_defence_pattern = get_defence_pattern_continuing(pattern)
        return get_hand_with_pattern(continuing_defence_pattern)
    else:
        return random_choice(get_max_actions())
