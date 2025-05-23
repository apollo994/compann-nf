process KEEP_SHORT_GENE{
	
    cache 'lenient'
    label 'agat'

    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
	input:
	path gff
    val max

	output:
	path "${gff.baseName}_0to${max}.gff3"

	script:
	"""
    agat_sp_filter_gene_by_length.pl -gff ${gff} --size $max --test "<" -o  ${gff.baseName}_0to${max}.gff3
	"""	

}
