process AGGREGATE_GFF{
    
    cache 'lenient'
    label 'python'
    
    publishDir params.outputFolder , mode: 'copy'

    input:
    val gff_stats
    
    output:
	path "gffcompare/summary/*"
    
    script:
    """
    mkdir -p gffcompare/summary
    hostname     
    python ${baseDir}/bin/aggregate_gffcompare.py \
        --gffcompare ${gff_stats.join(' ')} \
        --out_label gffcompare/summary/combined_gffcompare
    """

}
