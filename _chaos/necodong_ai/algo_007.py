def think(hands, history, old_games):
    import random

    debug = False
    full_hands = ['1', '2', '3', '4', '5']

    def random_choose(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

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

    if debug:
        print('idx of current game:', len(old_games) + 1)

        print('history:', history)
        # print('old_games:', old_games)
        print('your hands:', get_your_hands())
        print('my hands:', hands)

    if len(hands) >= 4:
        return random_choose(hands)
    else:
        return random_choose(get_max_actions())

