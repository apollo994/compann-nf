#! python3

import pandas as pd
import argparse
import os

def parse_file(file_path):
    """
    Parses the given file to extract relevant information.
    It expects the filename to start with a unique ID separated by '_'
    """
    data = []
    #tool = os.path.basename(file_path).split('_')[0].capitalize()
    full_or_200plus = "200+" if "200plus" in file_path else "Full"
    
    with open(file_path, 'r') as file:
        lines = file.readlines()[1:]  # Skip header
        for line in lines:
            parts = line.strip().split('\t')
            entry = {
                #'Tool': tool,
                'File Name': os.path.basename(file_path).split('_agat_stat')[0],
                'Full/200+': full_or_200plus,
                'Type': parts[0],  # assuming 3rd column corresponds to Type
                'Number': int(parts[1]),
                'Size total (kb)': float(parts[2]),
                'Size mean (bp)': float(parts[3])
            }
            data.append(entry)
    
    return data

def generate_summary_table(files):
    """
    Generates a summary table from the list of files.
    """
    all_data = []
    for file in files:
        file_data = parse_file(file)
        all_data.extend(file_data)
    
    df = pd.DataFrame(all_data)
    return df

def main():
    """
    Main function to process files and generate the summary table.
    """
    # Set up argument parsing
    parser = argparse.ArgumentParser(description='Generate a summary table from multiple agat_stat files.')
    parser.add_argument('--stats', nargs='+', help='List of input files to process.')
    parser.add_argument('--out', help='Name for the output aggregated csv')


    args = parser.parse_args()

    summary_table = generate_summary_table(args.stats)
    summary_table.to_csv(args.out, index=False)
    print(f"Summary table has been saved to {args.out}")


if __name__ == "__main__":
    main()
