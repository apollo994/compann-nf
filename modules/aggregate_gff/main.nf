process AGGREGATE_GFF{
    
    cache 'lenient'
    label 'python'
    
    publishDir params.outputFolder , mode: 'copy'

    input:
    tuple val(gff_stats), val(group)
    
    output:
	path "gffcompare/combined_gffcompare_${group}.tsv"
    
    script:
    """
    mkdir -p gffcompare/
    
    python ${baseDir}/bin/aggregate_gffcompare.py \
        --gffcompare ${gff_stats.join(' ')} \
        --out_label gffcompare/combined_gffcompare_${group}.tsv

    """


}
