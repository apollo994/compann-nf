process	RUN_BUSCO{

    cache 'lenient'
    label 'busco'
    cpus 4

    publishDir params.outputFolder , mode: 'copy'

	input:
	path transcripts
	val lineage

	output:
	path "BUSCO/all_samples/short_summary.specific.${lineage.baseName}.BUSCO_${transcripts}.json"
	
	script:
	"""
	busco \
        -m proteins \
        -i ${transcripts} \
        -l ${lineage} \
        --offline \
        --cpu 4 \
        -o BUSCO_${transcripts}

	mkdir -p BUSCO/all_samples
	
    mv BUSCO_${transcripts}/short_summary.specific.${lineage.baseName}.BUSCO_${transcripts}.json BUSCO/all_samples
	"""

}

