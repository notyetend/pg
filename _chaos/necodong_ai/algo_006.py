def think(hands, history, old_games):
    debug = False

    if debug:
        print('idx of current game:', len(old_games) + 1)
        print('hands:', hands)
        print('history:', history)
        print('old_games:', old_games)

    import random
    mat = [[0 for _ in range(6)] for _ in range(6)]
    full_hands = ['1', '2', '3', '4', '5']

    def random_choose(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    def update_mat(my_his, your_hit, weight):
        mat[my_his][your_hit] = mat[my_his][your_hit] + weight
        # new_value = mat[old_old_my_hit][old_your_hit] + (1 / (len(old_games)+1))
        # * (1 - mat[old_old_my_hit][old_your_hit])
        # new_value = mat[old_old_my_hit][old_your_hit] + 2.71828 * (1 - mat[old_old_my_hit][old_your_hit])

    def get_your_hands():
        return list(set(full_hands).difference({h[1] for h in history}))

    def get_old_my_hit(round_idx):
        if len(old_games) >= 1 and round_idx < 5:
            return old_games[-1][round_idx][1]
        else:
            return random_choose(full_hands)

    def get_this_your_prob():
        your_hands = get_your_hands()
        prob_all = mat[int(get_old_my_hit(len(history)))]
        prob_hands = {}
        for y in your_hands:
            prob_hands[y] = prob_all[int(y)]
        return prob_hands

    def get_max(lst):
        top = -1
        for l in lst:
            if l > top:
                top = l
        return top

    def get_your_most_probable():
        this_your_prob = get_this_your_prob()
        max_prob_val = get_max(list(this_your_prob.values()))
        max_prob_dict = {k: v for k, v in this_your_prob.items() if v == max_prob_val}
        if len(max_prob_dict) > 1:
            return random_choose(list(max_prob_dict.keys()))
        else:
            return list(max_prob_dict.keys())[0]

    def get_vs_my_hit():
        your_most_probable = get_your_most_probable()
        my_this_hit = None
        if your_most_probable == '5' and ('1' in hands):
            my_this_hit = '1'
        else:
            for h in sorted(hands):
                if h > your_most_probable:
                    my_this_hit = h
                    break
            if my_this_hit is None:
                my_this_hit = random_choose(hands)
        return my_this_hit

    if len(old_games) >= 2:  # this is 3rd game
        for i in range(len(old_games)-1):
            old_old_game = old_games[i]
            old_game = old_games[i+1]

            for j in range(len(old_old_game)):
                old_old_my_hit = int(old_old_game[j][0])
                old_your_hit = int(old_game[j][1])
                update_mat(old_old_my_hit, old_your_hit, i)

        for i, h in enumerate(history):
            this_your_hit = int(h[1])
            last_game = old_games[-1]
            old_my_hit = int(last_game[i][0])
            update_mat(old_my_hit, this_your_hit, len(old_games))

    if debug:
        print('mat:', mat)
        print('your hands:', get_your_hands())
        print('old my hit:', get_old_my_hit(len(history)))
        print('your prob:', get_this_your_prob())
        print('easy win hit:', get_your_most_probable())
        print('')

    return get_vs_my_hit()
