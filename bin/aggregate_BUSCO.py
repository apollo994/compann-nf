#! python3

import pandas as pd
import json
import argparse

def extract_from_BUSCO_json(path_to_json):
    res_dict = json.load(open(path_to_json))
    return res_dict

def get_df_from_BUSCO_res(json_res_list):
    df = pd.DataFrame()

    for r in json_res_list:
        sample_name = r.split('/')[-1].replace('.fa.json','')
        res_dict = extract_from_BUSCO_json(r)

        # get only lineage and results information
        refined_dict = {**res_dict['results'], **res_dict['lineage_dataset']}
        refined_df = pd.DataFrame.from_dict(refined_dict, orient='index')
        refined_df = refined_df.rename({0: sample_name}, axis='columns')
        df = pd.concat([df, refined_df], axis=1)

    return df

def main():
    parser = argparse.ArgumentParser(description='My nice tool.')
    parser.add_argument('--busco', nargs='+', help='A list of BUSCO output in json format')
    parser.add_argument('--out', help='Name for the output aggregated csv')

    args = parser.parse_args()

    out_df = get_df_from_BUSCO_res(args.busco)
    out_df.to_csv(f'{args.out}', index_label='metric')

if __name__ == "__main__":
    main()

    
