import pandas as pd
import argparse

def get_samples_dictionary(file_path):

    ref = file_path.split('/')[-1].split('_VS_')[0].replace('_longisoforms_200plus_basicelements','')
    query = file_path.split('/')[-1].split('_VS_')[1].replace('_longisoforms_200plus_basicelements.stats','')
    sample = f'{ref}_VS_{query}'

    res_dict = {'comparison': sample ,'ref':ref, 'query':query}
    
    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith('#= Summary for dataset:'):                
                lines = []
                for _ in range(18):
                    lines.append(file.readline().strip())
    
        for line in lines:
            
            if "#     Query mRNAs :" in line:
                query_mrnas = line.split(':')[1].split('in')[0].strip()
                res_dict['query_mrnas'] = int(query_mrnas)      
            if "# Reference mRNAs :" in line:
                reference_mrnas = line.split(':')[1].split('in')[0].strip()
                res_dict['reference_mrnas'] = int(reference_mrnas)        
            if "Base level" in line:
                base_level_Se = line.split(':')[-1].split('|')[0].strip()
                res_dict['base_level_Se'] = float(base_level_Se)         
                base_level_Pr = line.split(':')[-1].split('|')[1].strip()
                res_dict['base_level_Pr'] = float(base_level_Pr)          
            if "Exon level" in line:
                exon_level_Se = line.split(':')[-1].split('|')[0].strip()
                res_dict['exon_level_Se'] = float(exon_level_Se)         
                exon_level_Pr = line.split(':')[-1].split('|')[1].strip()
                res_dict['exon_level_Pr'] = float(exon_level_Pr)            
            if "Transcript level" in line:
                transcript_level_Se = line.split(':')[-1].split('|')[0].strip()
                res_dict['transcript_level_Se'] = float(transcript_level_Se)         
                transcript_level_Pr = line.split(':')[-1].split('|')[1].strip()
                res_dict['transcript_level_Pr'] = float(transcript_level_Pr)            
            if "Locus level" in line:
                locus_level_Se = line.split(':')[-1].split('|')[0].strip()
                res_dict['locus_level_Se'] = float(locus_level_Se)         
                locus_level_Pr = line.split(':')[-1].split('|')[1].strip()
                res_dict['locus_level_Pr'] = float(locus_level_Pr)            
            if "Matching intron chains" in line:
                matching_intron_chains = line.split(':')[-1].strip()
                res_dict['matching_intron_chains'] = int(matching_intron_chains)           
            if "Matching transcripts" in line:
                matching_transcripts = line.split(':')[-1].strip()
                res_dict['matching_transcripts'] = int(matching_transcripts)        
            if "Matching loci" in line:
                matching_loci = line.split(':')[-1].strip()
                res_dict['matching_loci'] = int(matching_loci)           
            if "Missed exons" in line:
                missed_exon_prop = line.split(':')[-1].split('\t')[0].strip()
                res_dict['missed_exon_prop'] = missed_exon_prop
                missed_exon_perc = line.split(':')[-1].split('\t')[-1].strip('( ').strip('%)')
                res_dict['missed_exon_perc'] = float(missed_exon_perc)            
            if "Novel exons" in line:
                novel_exon_prop = line.split(':')[-1].split('\t')[0].strip()
                res_dict['novel_exon_prop'] = novel_exon_prop
                novel_exon_perc = line.split(':')[-1].split('\t')[-1].strip('( ').strip('%)')
                res_dict['novel_exon_perc'] = float(novel_exon_perc)           
            if "Missed loci" in line:
                missed_loci_prop = line.split(':')[-1].split('\t')[0].strip()
                res_dict['missed_loci_prop'] = missed_loci_prop
                missed_loci_perc = line.split(':')[-1].split('\t')[-1].strip('( ').strip('%)')
                res_dict['missed_loci_perc'] = float(missed_loci_perc)            
            if "Novel loci" in line:
                novel_loci_prop = line.split(':')[-1].split('\t')[0].strip()
                res_dict['novel_loci_prop'] = novel_loci_prop
                novel_loci_perc = line.split(':')[-1].split('\t')[-1].strip('( ').strip('%)')
                res_dict['novel_loci_perc'] = float(novel_loci_perc)
            
    return res_dict

def calculate_f1(precision, recall):
    """Calculate the F1 score given precision and recall."""
    if precision + recall == 0:
        return 0
    return round(2 * (precision * recall) / (precision + recall),1)

def main():
    parser = argparse.ArgumentParser(description='My nice tool.')
    parser.add_argument('--gffcompare', nargs='+', help='A list of *.stats file from gffcompare')
    parser.add_argument('--out_label', help='Name for the output csv')

    args = parser.parse_args()
    
    res_df = pd.DataFrame()
    
    for stats in args.gffcompare:
        tmp_df = pd.DataFrame([get_samples_dictionary(stats)])
        res_df = pd.concat([res_df, tmp_df])
    
    for level in ['base', 'exon', 'transcript', 'locus']:
    
        res_df[f'{level}_level_F1'] = res_df.apply(
            lambda row: calculate_f1(row[f'{level}_level_Pr'], row[f'{level}_level_Se']),
            axis=1
        )
    
    res_df = res_df.melt(id_vars=['comparison','ref','query'],
                         value_vars=['query_mrnas',
                                     'reference_mrnas',
                                     'base_level_Se',
                                     'base_level_Pr',
                                     'base_level_F1',
                                     'exon_level_Se',
                                     'exon_level_Pr',
                                     'exon_level_F1',
                                     'transcript_level_Se',
                                     'transcript_level_Pr',
                                     'transcript_level_F1',
                                     'locus_level_Se',
                                     'locus_level_Pr',
                                     'locus_level_F1',
                                     'matching_intron_chains',
                                     'matching_transcripts',
                                     'matching_loci',
                                     'missed_exon_prop',
                                     'missed_exon_perc',
                                     'novel_exon_prop'
                                     ,'novel_exon_perc'])

    
    res_df.to_csv(f'{args.out_label}_extend.tsv', index=False)


if __name__ == "__main__":
    main()

    
