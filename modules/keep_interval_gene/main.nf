process KEEP_INTERVAL_GENE{
	
    cache 'lenient'
    label 'agat'

    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
	input:
	path gff
    tuple val(min), val(max)

	output:
	path "${gff.baseName}_${min}to${max}.gff3"

	script:
	"""
    agat_sp_filter_gene_by_length.pl -gff ${gff} --size ${min} --test ">=" -o  tmp.gff3
    agat_sp_filter_gene_by_length.pl -gff tmp --size ${max} --test "<" -o  ${gff.baseName}_${min}to${max}.gff3
	"""	

}
