def match_one_round(res1, res2):
    try:
        res1 = int(res1)
    except ValueError:
        res1 = None
    try:
        res2 = int(res2)
    except ValueError:
        res2 = None

    if res1 is None or res2 is None:
        if res1 is None and res2 is None:
            raise (Exception('Both code are wrong'))
        elif res1 is None:
            raise (Exception('RES1 code are wrong'))
        elif res2 is None:
            raise (Exception('RES2 code are wrong'))
        else:
            raise (Exception("Unknown Exception occurred"))

    if res1 == res2:
        return 0
    elif (res1 == 1) and (res2 == 5):
        return -1
    elif (res1 == 5) and (res2 == 1):
        return 1
    else:
        if res1 < res2:
            return 1
        elif res1 > res2:
            return -1


def match(think1, think2):
    score_1 = 0
    score_2 = 0

    old_games_1 = []
    old_games_2 = []

    num_match = 3
    for i in range(1, num_match + 1):  # 1 ~ 11 Matches
        _score = 0
        hands_1 = ['1', '2', '3', '4', '5']
        hands_2 = ['1', '2', '3', '4', '5']
        history_1 = []
        history_2 = []
        for _ in range(5):  # 5 rounds
            res1 = think1(hands_1.copy(), history_1.copy(), old_games_1.copy())
            res2 = think2(hands_2.copy(), history_2.copy(), old_games_2.copy())
            hands_1.remove(res1)
            hands_2.remove(res2)
            _score += match_one_round(res1, res2)
            history_1.append([res1, res2])
            history_2.append([res2, res1])
        if _score < 0:  # Player 1 wins
            score_1 += 1
        elif _score > 0:  # Player 2 wins
            score_2 += 1
        old_games_1.append(history_1)
        old_games_2.append(history_2)

    # print(score_1, score_2)

    return score_1 / num_match, score_2 / num_match
    '''
    if score_1 > score_2:
        # print('Player 1 Wins')
        return -1
    elif score_2 > score_1:
        # print('Player 2 Wins')
        return 1
    else:
        # print('Draw')
        return 0
    '''


if __name__ == '__main__':
    import os
    from collections import defaultdict

    # List all .py in dir
    func_list = []
    func_dict = {}
    win_score = defaultdict(lambda: 0, {})
    # import all .pyfiles in dir
    for file in os.listdir():
        if '.py' not in file:  # Not Python file
            continue
        if 'playground' not in file:
            try:
                funcname = file.replace('.py', '')
                exec("from {f} import think as think_{f}".format(f=funcname))
            except Exception as e:  # No 'think' function
                # print(e)
                continue
            exec("func_list.append(think_{})".format(funcname))
            exec("func_dict[think_{}] = '{}'".format(funcname, funcname))
    func_list_2 = func_list.copy()
    for think1 in func_list:
        func_list_2.remove(think1)
        for think2 in func_list_2:
            score1, score2 = match(think1, think2)
            win_score[think1] += score1
            win_score[think2] += score2
            '''
            res = match(think1, think2)
            if res == -1:
                win_score[think1] += 3
            elif res == 1:
                win_score[think2] += 3
            else:
                win_score[think1] += 1
                win_score[think2] += 1
            '''
    print("=== RESULT ===")
    for k, v in dict(win_score).items():
        func_name = func_dict[k]
        print(func_name, ':', v)