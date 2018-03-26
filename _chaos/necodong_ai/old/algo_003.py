def think(hands, history, old_games):
    import random

    def random_choose(val_list):
        return val_list[int(random.uniform(0, len(val_list)))]

    return random_choose(hands)
