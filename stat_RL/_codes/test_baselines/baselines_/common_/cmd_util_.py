def arg_parser_():
    import argparse
    return argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)


def atari_arg_parser_():
    parser = arg_parser_()
    parser.add_argument('--end', help='environment ID', default='BreakoutNoFrameskip-v4')
    parser.add_argument('--seed', help='RNG seed', type=int, default=0)
    parser.add_argument('--num-timestep', type=int, default=int(10e6))
    return parser
