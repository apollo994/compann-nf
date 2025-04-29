
process GET_GFF_STATS_LONG{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
	
	output:
	path "summary_stat/long/${gff.baseName}_agat_stat.txt"

	script:
	"""
    mkdir -p summary_stat/long
	agat_sq_stat_basic.pl -i ${gff} -o summary_stat/long/${gff.baseName}_agat_stat.txt
	"""


}

