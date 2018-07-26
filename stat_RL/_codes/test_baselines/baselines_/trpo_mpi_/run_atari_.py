from baselines_.common_.cmd_util_ import atari_arg_parser_


def train(env_id, run_timesteps, seed):
    from baselines_.trpo_mpi_.nosharing_cnn_policy_ import CnnPolicy_


def main():
    args = atari_arg_parser_().parse_args()
    # train()


if __name__ == "__main__":
    main()


