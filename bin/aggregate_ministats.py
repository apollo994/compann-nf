#!/usr/bin/env python3
"""
Combine *_ministast.tsv files into one CSV.

The *segment* label is taken from the parent directory name,
e.g.  .../ALL/file.tsv      -> segment =  ALL
      .../from0_to200/file.tsv -> segment =  from0_to200
"""

import argparse
import pathlib
import pandas as pd


# ----------------------------------------------------------------------
def parse_ministat(path: pathlib.Path) -> pd.DataFrame:
    """
    Read one *_ministast.tsv and return a small DataFrame
    with the desired columns plus the segment label.
    """
    segment = path.parent.name                 # ALL, from0_to200, …

    df = pd.read_csv(path, sep="\t")           # original table
    df = df.loc[:, ["Feature",
                    "Features_Count",
                    "Total_Feature_Length",
                    "Average_Feature_Length",
                    "Genome_Percentage"]]  # keep only these cols

    df.rename(columns={
        "Feature"               : "Type",
        "Features_Count"        : "Number",
        "Total_Feature_Length"  : "Size total (kb)",
        "Average_Feature_Length": "Size mean (bp)",
        "Genome_Percentage"     : "Genome percentage (%)"
    }, inplace=True)

    df.insert(0, "Sample", path.stem.replace("_ministast", "").replace(f"_{segment}",""))
    df.insert(1, "Segment",   segment)
    return df


# ----------------------------------------------------------------------
def build_summary(file_list):
    frames = [parse_ministat(pathlib.Path(f).resolve())
              for f in file_list]
    return pd.concat(frames, ignore_index=True)


# ----------------------------------------------------------------------
def main():
    p = argparse.ArgumentParser(
        description="Aggregate mini-stats TSV files into one CSV.")
    p.add_argument("files", nargs="+",
                   help="Paths to *_ministast.tsv files (space-separated).")
    p.add_argument("-o", "--out", default="combined_ministats.csv",
                   help="Output CSV filename [%(default)s]")
    args = p.parse_args()

    summary = build_summary(args.files)
    summary.to_csv(args.out, index=False)
    print(f"✓ wrote {len(summary)} rows to {args.out}")


# ----------------------------------------------------------------------
if __name__ == "__main__":
    main()
