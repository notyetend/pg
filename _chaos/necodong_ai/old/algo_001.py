'''
def think(hands, history, old_games):
    if len(hands) == 5:
        return '5'
    if len(hands) == 4:
        return '4'
    if len(hands) == 3:
        return '3'
    if len(hands) == 2:
        return '2'
    if len(hands) == 1:
        return '1'
'''
def think(hands, history, old_games):
    import random

    def random_choose(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    return random_choose(hands)
