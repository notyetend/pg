import argparse
import pandas as pd
import trueskill as ts
import pandasql as pdsql
from scipy.stats import norm
from datetime import datetime


pdf = norm.pdf
cdf = norm.cdf
icdf = norm.ppf  # inverse CDF
init_mu = 25
init_sigma = init_mu / 3
init_beta = init_sigma / 2
init_gamma = init_sigma / 100
init_draw_probability = 0.1

env = None

col_name_reg_date = 'reg_date'
col_name_match_id = 'match_id'
col_name_team_no = 'team_no'
col_name_player_id = 'player_id'
col_name_result = 'result'


def get_iter_match(df):
    """
    df: Pandas dataframe

    yielding match : dict {
        result_code0: [player, ...]
        , result_code1: [player, ...]
        , ...
    }
    """

    def get_transformed_df(df):
        query = """
        select
            t2.match_min_reg_date
            , t1.*
        from 
            df as t1
            inner join
            (
                select 
                    """ + col_name_match_id + """
                    , min(""" + col_name_reg_date + """) as match_min_reg_date
                from 
                    df
                group by 
                    """ + col_name_match_id + """ 
            ) as t2
            on
                t1.""" + col_name_match_id + """ = t2.""" + col_name_match_id + """
        order by
            t2.match_min_reg_date
            , t1.""" + col_name_match_id + """
            , t1.""" + col_name_result
        return pdsql.sqldf(query, locals())

    def append_player(_match, _player):
        team_no = _player[col_name_team_no]
        if _match.get(team_no) is None:  # new team encountered
            _match[team_no] = [_player]
        else:
            _match[team_no].append(_player)

    last_match_id = None
    match = {}

    df = get_transformed_df(df)

    for idx, row in df.iterrows():
        player = row.to_dict()
        this_match_id = player[col_name_match_id]

        if idx == 0 or last_match_id == this_match_id:  # 1st record or same match with last record
            append_player(match, player)
        else:  # new match record started
            yield match
            match = {}
            append_player(match, player)

        last_match_id = this_match_id

    yield match


def update_match_result(rating_store, match):
    """

    :param rating_store: instance of RatingStore
    :param match:
    :param env: trueskill environment
    :return: None
    """

    def get_rating_groups():
        """
        rate function of trueskill package requires rating_groups and ranks as arg.
        so we build these two things first.

        and we assume player's current rating is always exist in the rating store.
        """
        _rating_groups = []
        _ranks = []

        for i, (result, team_members) in enumerate(match.items()):  # for each team(result) in the match
            _rating_groups.append(dict())
            for j, player in enumerate(team_members):  # for each player in the team
                if j == 0:
                    _ranks.append(player[col_name_result])

                player['rating_before'] = d_rating = rating_store.get_player_rating(player[col_name_player_id])
                _rating_groups[i][player[col_name_player_id]] = env.Rating(d_rating.get('scroe1'),
                                                                           d_rating.get('score2'))
        return _rating_groups, _ranks

    def set_rating_after(rating_after):
        """
        add 'rating_after' key in the match dict
            which having updated player's rating after the match.
        """
        for team_no, team_members in match.items():
            for i, player in enumerate(team_members):
                if player[col_name_player_id] == player_id:
                    match[team_no][i]['rating_after'] = rating_after
                else:
                    pass

    rating_groups, ranks = get_rating_groups()
    rating_groups_after = env.rate(rating_groups, ranks)  # calculating updated rating after the match.

    for i, rating_group in enumerate(rating_groups_after):
        for player_id, ts_rating_after in rating_group.items():
            d_rating_after = {"score1": ts_rating_after.mu, "score2": ts_rating_after.sigma}
            set_rating_after(d_rating_after)
            rating_store.update_rating(player_id, d_rating_after)


class RatingStore:
    def __init__(self, mmrtype: str, default_rating=None):

        self.store = dict()  # {"playerid":{"score1":val1, "score2":val2}}

        # validation for mmrtype
        if mmrtype.lower() not in {'trueskill', 'elo'}:
            raise ValueError('Unknown mmrtype')
        else:
            self.mmrtype = mmrtype.lower()  # 'trueskill', 'elo', 'glicko', ...

        if default_rating is None:
            if self.mmrtype == 'trueskill':
                self.default_rating = {'score1': 25, 'score2': 8.333}
            elif self.mmrtype == 'elo':
                self.default_rating = {'score1': 1200}

    def get_player_rating(self, player_id):
        # if it's new player then return default value, or return existing rating
        return self.store.get(player_id) or self.default_rating

    def update_rating(self, player_id, rating):
        """
        rating: score list
            for trueskill, rating is lengh 2 list
            for elo, rating is length 1 list or scalar
        """
        # validation for rating that will be updated as.
        if isinstance(rating, dict):
            pass
        else:
            raise ValueError('Invalid rating type. this should be dict, likes {"score1":25, "score2":8.333}')

        self.store[player_id] = rating

    def __repr__(self):
        repr_parts = []
        for p, r in self.store.items():
            repr_parts.append(str(p) + ': ' + str(r))
        return '\n'.join(repr_parts)


def main():
    global col_name_reg_date
    global col_name_match_id
    global col_name_team_no
    global col_name_player_id
    global col_name_result
    global env
    global init_mu
    global init_sigma
    global init_beta
    global init_gamma
    global init_draw_probability

    file_name = args.excel_file_path
    input_sheet_name = args.excel_file_sheet
    output_sheet_name = 'out_' + datetime.now().strftime('%Y-%m-%d %H%M%S')

    col_name_reg_date = args.col_name_reg_date or 'reg_date'
    col_name_match_id = args.col_name_match_id or 'match_id'
    col_name_team_no = args.col_name_team_no or 'team_no'
    col_name_player_id = args.col_name_player_id or 'player_id'
    col_name_result = args.col_name_result or 'result'

    init_mu = args.init_mu or 25
    init_sigma = args.init_sigma or 8.333333333333334
    init_beta = args.init_beta or 4.166666666666667
    init_gamma = args.init_gamma or 0.08333333333333334
    init_draw_probability = args.init_draw_prob or 0.1

    env = ts.TrueSkill(mu=init_mu
                       , sigma=init_sigma
                       , beta=init_beta
                       , tau=init_gamma
                       , draw_probability=init_draw_probability
                       , backend='scipy')

    print('Loading... ', '[' + file_name + ' : ' + str(input_sheet_name) + ']')
    dfx = pd.read_excel(io=file_name, sheet_name=input_sheet_name, header=0)
    print('Total', str(len(dfx)) + 'rows loaded')
    match_history = list(get_iter_match(dfx))

    rating_store = RatingStore('trueskill')

    for match in match_history:  # for each match(dict those key is teamno.
        update_match_result(rating_store, match)

    dict_list = []
    for match in match_history:
        for team in match.values():
            for player in team:
                dict_list.append(player)

    df_out = pd.DataFrame(dict_list)

    ordered_head = list(dfx)
    for h in list(df_out):
        if h not in set(list(dfx)):
            ordered_head.append(h)

    df_out = df_out[ordered_head]
    ws_dict = pd.read_excel(file_name, sheet_name=None)
    ws_dict[output_sheet_name] = df_out

    try:
        with pd.ExcelWriter(file_name
                , engine='xlsxwriter'
                , datetime_format='yyyy-mm-dd'
                , date_format='yyyy-mm-dd') as writer:
            for ws_name, df_sheet in ws_dict.items():
                df_sheet.to_excel(writer, sheet_name=ws_name, index=False)
    except PermissionError as e:
        print('File is opened, so failed writing output. Please close file first.')
        raise e
    print('Output is exported into', '[' + file_name + output_sheet_name + ' : ' + str(output_sheet_name) + ']')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('excel_file_path', help="(MANDATORY) Where your excel file is located? \\"
                                                "(full path including file name and extension")
    parser.add_argument('excel_file_sheet', help="(MANDATORY) Excel sheet name containing input data.")
    parser.add_argument('--col_name_reg_date', help="(OPTIONAL) Column name for the match started datetime. \\"
                                                    "Default value is 'reg_date'")
    parser.add_argument('--col_name_match_id', help="(OPTIONAL) Column name for the identifier of each match. \\"
                                                    "Default value is 'match_id'")
    parser.add_argument('--col_name_team_no', help="(OPTIONAL) Column name for the identifier of each team. \\"
                                                   "Default value is 'team_no'")
    parser.add_argument('--col_name_player_id', help="(OPTIONAL) Column name for the identifier of each player")
    parser.add_argument('--col_name_result', help="(OPTIONAL) Column name for game result(win, lose or draw)")
    parser.add_argument('--init_mu', help="(OPTIONAL) initial mu for trueskill. \\"
                                          "Default value is 25")
    parser.add_argument('--init_sigma', help="(OPTIONAL) initial sigma for trueskill. \\"
                                             "Default value is 8.333333333333334")
    parser.add_argument('--init_beta', help="(OPTIONAL) initial beta for trueskill. \\"
                                            "Default value is 4.16666666666666")
    parser.add_argument('--init_gamma', help="(OPTIONAL) initial gamma for trueskill. \\"
                                             "Default value is 0.08333333333333334")
    parser.add_argument('--init_draw_prob', help="(OPTIONAL) initial draw probability for trueskill. \\"
                                                 "Default value is 0.1")
    args = parser.parse_args()
    main()
