
process GET_GFF_STATS{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
	
	output:
	path "summary_stat/full/${gff.baseName}_agat_stat.txt"

	script:
	"""
    mkdir -p summary_stat/full
	agat_sq_stat_basic.pl -i ${gff} -o summary_stat/full/${gff.baseName}_agat_stat.txt
	"""


}

