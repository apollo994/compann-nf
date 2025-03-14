process KEEP_LONG_GENE{
	
    cache 'lenient'
    label 'agat'

    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
	input:
	path gff

	output:
	path "${gff.baseName}_200plus.gff3"

	script:
	"""
    agat_sp_filter_gene_by_length.pl -gff ${gff} --size 200 --test ">" -o  ${gff.baseName}_200plus.gff3
	"""	

}
