def think(hands, history, old_games):
    import random

    def random_choose(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    print('idx of current game:', len(old_games) + 1)
    print('history:', history)
    print('old_games:', old_games)

    idx_current_game = len(old_games) + 1
    state_mat = [[0 for _ in range(6)] for _ in range(6)]
    if idx_current_game > 1:
        for old_game in old_games:
            for match in old_game:

                me = int(match[0])
                you = int(match[1])

                print('me:', me, ' you:', you)

                new_value = state_mat[me][you] + (1/idx_current_game) * (1 - state_mat[me][you])
                state_mat[me][you] = new_value
    return random_choose(hands)
