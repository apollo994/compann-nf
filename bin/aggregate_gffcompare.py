import pandas as pd
import argparse

def get_samples_dictionary(file_path):   
    sample_dictionary = {}       
    with open(file_path, 'r') as file:        
        ref_name = file_path.split('/')[-1].replace('_longisoforms_200plus_basicelements.stats','')
        
        for line in file:
            if line.startswith('#= Summary for dataset:'):                
                sample_name = line.split('/')[-1].split('_longisoforms_200plus_basicelements')[0]
                comparison_name = f'{ref_name}_vs_{sample_name}'
                sample_dictionary[comparison_name] = []
                for _ in range(18):
                    sample_dictionary[comparison_name].append(file.readline().strip())    
    return sample_dictionary

def parse_single_comparison(lines_list):
    
    res_dict = {}
    
    for line in lines_list:
        
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



def combine_gffcompare_res(gffcompare_stats_list):
    
    df = pd.DataFrame()
    
    for f in gffcompare_stats_list:
        
        sample_name = f.split('/')[-1].replace('_longisoforms_200plus_basicelements.stats','')       
        samples_dict = get_samples_dictionary(f)
        column_to_add = pd.DataFrame()
        
        for comparison in samples_dict:
            
            comparison_dict = parse_single_comparison(samples_dict[comparison])
            comparison_dict = {f'{comparison}-{k}':v for k,v in comparison_dict.items()}
            comparison_df = pd.DataFrame.from_dict(comparison_dict, orient='index')
            column_to_add = pd.concat([column_to_add, comparison_df])
            
        column_to_add = column_to_add.rename({0:sample_name}, axis='columns')
        
        df = pd.concat([df, column_to_add], axis=1)

    return df

#def get_matrix(large_df, metric):
#    
#    samples = list(large_df.columns)
#    res_df = pd.DataFrame(index=samples, columns=samples)
#    
#    for sample in samples:        
#        for i in range(len(samples)):
#            interesting_row = f'{sample}_vs_{samples[i]}_{metric}'
#            val = large_df.loc[interesting_row,sample]
#            res_df.loc[sample, samples[i]] = val
#            res_df = res_df[res_df.columns].astype(float)
#    
#    return res_df


def main():
    parser = argparse.ArgumentParser(description='My nice tool.')
    parser.add_argument('--gffcompare', nargs='+', help='A list of *.stats file from gffcompare')
    parser.add_argument('--out_label', help='Name for the output csv')

    args = parser.parse_args()

    large_df = combine_gffcompare_res(args.gffcompare)
    large_df.to_csv(f'{args.out_label}_extend.tsv', index_label='comparison')
    
#    for m in ['base_level_Se',
#              'base_level_Pr',
#              'transcript_level_Se',
#              'transcript_level_Pr']:
#        
#        metric_matrix = get_matrix(large_df, m)
#        metric_matrix.to_csv(f'{args.out_label}_{m}.csv')


if __name__ == "__main__":
    main()

    
