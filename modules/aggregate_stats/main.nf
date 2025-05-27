process AGGREGATE_STATS{
    
    cache 'lenient'
    label 'python'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val all_ministats
    
    output:
	path "summary_stat/combined_ministats.csv"
    
    script:
    """
    mkdir -p summary_stat/mini

    python ${baseDir}/bin/aggregate_ministats.py \
                            ${all_ministats.join(' ')} \
                            -o summary_stat/combined_ministats.csv

            
    """
}
