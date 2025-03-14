process AGGREGATE_BUSCO{
    
    cache 'lenient'
    label 'python'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val BUSCO_stats
    
    output:
	path "BUSCO/summary/combined_BUSCO_results.csv"
    
    script:
    """
    mkdir -p BUSCO/summary
    python ${baseDir}/bin/aggregate_BUSCO.py \
        --busco ${BUSCO_stats.join(' ')} \
        --out BUSCO/summary/combined_BUSCO_results.csv
    """
}

