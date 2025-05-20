process AGGREGATE_STATS{
    
    cache 'lenient'
    label 'python'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val full_stats
    val long_stats
    
    output:
	path "summary_stat/summary_stats_combined.csv"
    
    script:
    """
    mkdir -p summary_stat
    python ${baseDir}/bin/aggregate_stats.py \
        --stats ${full_stats.join(' ')} ${long_stats.join(' ')} \
        --out summary_stat/summary_stats_combined.csv
    """
}
