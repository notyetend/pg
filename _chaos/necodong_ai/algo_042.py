def think(hands, history, old_games):
    import random

    if len(old_games) < 2:
        return random.choice(hands)
    else:
        yours = ''
        for y in old_games[-1]:
            yours += str(y[1])

        mine = ''
        for m in yours:
            mine += str(int(m) % 5 + 1)
        return mine[5-len(hands)]
